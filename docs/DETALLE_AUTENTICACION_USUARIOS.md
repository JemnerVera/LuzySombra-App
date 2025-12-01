# 🔐 Detalle Completo: Autenticación de Usuarios Web

Este documento detalla paso a paso cómo implementar un sistema completo de autenticación de usuarios web para la aplicación LuzSombra.

---

## 📋 Tabla de Contenidos

1. [Arquitectura General](#arquitectura-general)
2. [Estructura de Base de Datos](#estructura-de-base-de-datos)
3. [Backend - Implementación Completa](#backend---implementación-completa)
4. [Frontend - Implementación Completa](#frontend---implementación-completa)
5. [Sistema de Roles y Permisos](#sistema-de-roles-y-permisos)
6. [Flujo de Autenticación](#flujo-de-autenticación)
7. [Seguridad y Mejores Prácticas](#seguridad-y-mejores-prácticas)
8. [Plan de Implementación](#plan-de-implementación)

---

## 🏗️ Arquitectura General

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Frontend  │ ──────> │   Backend    │ ──────> │  SQL Server │
│  (React)    │         │  (Express)   │         │  (MAST.USERS)│
└─────────────┘         └──────────────┘         └─────────────┘
      │                        │
      │                        │
      ▼                        ▼
┌─────────────┐         ┌──────────────┐
│  JWT Token  │         │   bcrypt     │
│ (localStorage)│        │  (hash pwd)  │
└─────────────┘         └──────────────┘
```

### Componentes Principales:

1. **Frontend:**
   - Página de Login
   - Contexto de Autenticación (React Context)
   - Protección de Rutas
   - Interceptor de Axios

2. **Backend:**
   - Endpoints de autenticación
   - Middleware de autenticación
   - Middleware de autorización
   - Servicio de usuarios

3. **Base de Datos:**
   - Tabla de usuarios (MAST.USERS o nueva)
   - Tabla de roles/permisos (opcional)

---

## 🗄️ Estructura de Base de Datos

### ✅ **Decisión: Crear Tabla Específica `evalImagen.UsuarioWeb`**

**Razón:** `MAST.USERS` se usa para diferentes propósitos en el sistema y puede complicar la implementación. Es mejor tener una tabla dedicada para autenticación web.

**Script:** `scripts/01_tables/09_evalImagen.UsuarioWeb.sql`

**Ver script completo:** `scripts/01_tables/09_evalImagen.UsuarioWeb.sql`

**Campos principales:**
- `usuarioID` (PK) - ID único del usuario
- `username` - Nombre de usuario único
- `passwordHash` - Hash bcrypt de la contraseña
- `email` - Email único
- `nombreCompleto` - Nombre completo del usuario
- `rol` - Rol: Admin, Agronomo, Supervisor, Lector
- `activo` - Si el usuario está activo
- `intentosLogin` - Contador de intentos fallidos
- `bloqueadoHasta` - Fecha hasta la cual está bloqueado
- `ultimoAcceso` - Última vez que hizo login
- Campos de auditoría estándar (statusID, fechaCreacion, etc.)

**Índices creados:**
- `IDX_UsuarioWeb_Username` - Para búsqueda rápida en login
- `IDX_UsuarioWeb_Email` - Para búsqueda por email
- `IDX_UsuarioWeb_RolActivo` - Para filtros por rol y estado

---

## 🔧 Backend - Implementación Completa

### 1. Instalar Dependencias

```bash
cd backend
npm install bcrypt jsonwebtoken
npm install --save-dev @types/bcrypt @types/jsonwebtoken
```

### 2. Configurar Variables de Entorno

```env
# .env.local
JWT_SECRET=tu-secret-key-super-segura-cambiar-en-produccion
JWT_EXPIRES_IN=24h
BCRYPT_ROUNDS=10
```

### 3. Crear Servicio de Usuarios

**`backend/src/services/userService.ts`:**

```typescript
import bcrypt from 'bcrypt';
import { query } from '../lib/db';

export interface Usuario {
  usuarioID: number;
  username: string;
  email: string;
  nombreCompleto: string | null;
  rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
  activo: boolean;
  ultimoAcceso: Date | null;
}

export interface UsuarioConPassword extends Usuario {
  passwordHash: string;
}

/**
 * Servicio para gestionar usuarios web
 */
class UserService {
  private readonly bcryptRounds = parseInt(process.env.BCRYPT_ROUNDS || '10');

  /**
   * Busca un usuario por username
   */
  async findByUsername(username: string): Promise<UsuarioConPassword | null> {
    try {
      const rows = await query<UsuarioConPassword>(`
        SELECT 
          usuarioID,
          username,
          passwordHash,
          email,
          nombreCompleto,
          rol,
          activo,
          ultimoAcceso
        FROM evalImagen.UsuarioWeb
        WHERE username = @username
          AND statusID = 1
      `, { username });

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('❌ Error buscando usuario:', error);
      throw error;
    }
  }

  /**
   * Verifica si la contraseña es correcta
   */
  async verifyPassword(
    password: string,
    passwordHash: string
  ): Promise<boolean> {
    try {
      return await bcrypt.compare(password, passwordHash);
    } catch (error) {
      console.error('❌ Error verificando contraseña:', error);
      return false;
    }
  }

  /**
   * Hashea una contraseña
   */
  async hashPassword(password: string): Promise<string> {
    return await bcrypt.hash(password, this.bcryptRounds);
  }

  /**
   * Actualiza último acceso del usuario
   */
  async updateLastAccess(usuarioID: number): Promise<void> {
    try {
      await query(`
        UPDATE evalImagen.UsuarioWeb
        SET ultimoAcceso = GETDATE()
        WHERE usuarioID = @usuarioID
      `, { usuarioID });
    } catch (error) {
      console.warn('⚠️ No se pudo actualizar último acceso:', error);
    }
  }

  /**
   * Incrementa intentos de login fallidos
   */
  async incrementFailedAttempts(usuarioID: number): Promise<void> {
    try {
      await query(`
        UPDATE evalImagen.UsuarioWeb
        SET intentosLogin = intentosLogin + 1,
            bloqueadoHasta = CASE 
              WHEN intentosLogin >= 4 THEN DATEADD(MINUTE, 15, GETDATE())
              ELSE bloqueadoHasta
            END
        WHERE usuarioID = @usuarioID
      `, { usuarioID });
    } catch (error) {
      console.warn('⚠️ No se pudo actualizar intentos:', error);
    }
  }

  /**
   * Resetea intentos de login fallidos
   */
  async resetFailedAttempts(usuarioID: number): Promise<void> {
    try {
      await query(`
        UPDATE evalImagen.UsuarioWeb
        SET intentosLogin = 0,
            bloqueadoHasta = NULL
        WHERE usuarioID = @usuarioID
      `, { usuarioID });
    } catch (error) {
      console.warn('⚠️ No se pudo resetear intentos:', error);
    }
  }

  /**
   * Verifica si el usuario está bloqueado
   */
  async isUserBlocked(usuarioID: number): Promise<boolean> {
    try {
      const rows = await query<{ bloqueadoHasta: Date | null }>(`
        SELECT bloqueadoHasta
        FROM evalImagen.UsuarioWeb
        WHERE usuarioID = @usuarioID
      `, { usuarioID });

      if (rows.length === 0) return true;

      const bloqueadoHasta = rows[0].bloqueadoHasta;
      if (!bloqueadoHasta) return false;

      // Si ya pasó el tiempo de bloqueo, desbloquear
      if (new Date(bloqueadoHasta) < new Date()) {
        await this.resetFailedAttempts(usuarioID);
        return false;
      }

      return true;
    } catch (error) {
      console.error('❌ Error verificando bloqueo:', error);
      return false;
    }
  }

  /**
   * Obtiene permisos del usuario según su rol
   */
  getPermissions(rol: string): string[] {
    const PERMISOS: Record<string, string[]> = {
      Admin: ['*'], // Todo
      Agronomo: [
        'umbrales:read',
        'umbrales:write',
        'alertas:read',
        'alertas:write',
        'alertas:resolve',
        'contactos:read',
        'contactos:write',
        'dashboard:read',
        'historial:read',
        'dispositivos:read'
      ],
      Supervisor: [
        'alertas:read',
        'alertas:resolve',
        'contactos:read',
        'dashboard:read',
        'historial:read'
      ],
      Lector: [
        'dashboard:read',
        'historial:read',
        'alertas:read'
      ]
    };

    return PERMISOS[rol] || PERMISOS['Lector'];
  }
}

export const userService = new UserService();
```

### 4. Crear Rutas de Autenticación

**`backend/src/routes/auth-web.ts`:**

```typescript
import express, { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { userService } from '../services/userService';
import { authenticateWebUser } from '../middleware/auth-web';

const router = express.Router();

/**
 * POST /api/auth/web/login
 * Autenticación de usuario web
 * 
 * Body:
 * - username: Nombre de usuario
 * - password: Contraseña
 */
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    // Validaciones
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        error: 'username y password son requeridos'
      });
    }

    // Buscar usuario
    const usuario = await userService.findByUsername(username);

    if (!usuario) {
      return res.status(401).json({
        success: false,
        error: 'Credenciales inválidas'
      });
    }

    // Verificar si está activo
    if (!usuario.activo) {
      return res.status(403).json({
        success: false,
        error: 'Usuario desactivado. Contacta al administrador.'
      });
    }

    // Verificar si está bloqueado
    const isBlocked = await userService.isUserBlocked(usuario.usuarioID);
    if (isBlocked) {
      return res.status(423).json({
        success: false,
        error: 'Usuario temporalmente bloqueado por múltiples intentos fallidos. Intenta en 15 minutos.'
      });
    }

    // Verificar contraseña
    const passwordValid = await userService.verifyPassword(
      password,
      usuario.passwordHash
    );

    if (!passwordValid) {
      // Incrementar intentos fallidos
      await userService.incrementFailedAttempts(usuario.usuarioID);
      
      return res.status(401).json({
        success: false,
        error: 'Credenciales inválidas'
      });
    }

    // Login exitoso - resetear intentos
    await userService.resetFailedAttempts(usuario.usuarioID);
    await userService.updateLastAccess(usuario.usuarioID);

    // Generar JWT token
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    const token = jwt.sign(
      {
        usuarioID: usuario.usuarioID,
        username: usuario.username,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      },
      jwtSecret,
      { expiresIn }
    );

    // Calcular expiración en segundos
    const expiresInSeconds = expiresIn === '24h' ? 86400 : 
                            expiresIn === '7d' ? 604800 : 3600;

    res.json({
      success: true,
      token,
      expiresIn: expiresInSeconds,
      user: {
        id: usuario.usuarioID,
        username: usuario.username,
        email: usuario.email,
        nombreCompleto: usuario.nombreCompleto,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      }
    });
  } catch (error) {
    console.error('❌ Error en login:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/auth/web/logout
 * Cerrar sesión (principalmente para logging/auditoría)
 */
router.post('/logout', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    // Aquí podrías invalidar el token en una blacklist
    // Por ahora solo confirmamos el logout
    res.json({
      success: true,
      message: 'Sesión cerrada exitosamente'
    });
  } catch (error) {
    console.error('❌ Error en logout:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * GET /api/auth/web/me
 * Obtener información del usuario actual
 */
router.get('/me', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    const usuarioID = (req as any).user.usuarioID;

    // Buscar usuario actualizado
    const usuario = await userService.findByUsername((req as any).user.username);
    
    if (!usuario || !usuario.activo) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no encontrado o desactivado'
      });
    }

    res.json({
      success: true,
      user: {
        id: usuario.usuarioID,
        username: usuario.username,
        email: usuario.email,
        nombreCompleto: usuario.nombreCompleto,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      }
    });
  } catch (error) {
    console.error('❌ Error obteniendo usuario:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

/**
 * POST /api/auth/web/refresh
 * Refrescar token (extender sesión)
 */
router.post('/refresh', authenticateWebUser, async (req: Request, res: Response) => {
  try {
    const user = (req as any).user;
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const expiresIn = process.env.JWT_EXPIRES_IN || '24h';

    // Verificar que el usuario sigue activo
    const usuario = await userService.findByUsername(user.username);
    
    if (!usuario || !usuario.activo) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no encontrado o desactivado'
      });
    }

    // Generar nuevo token
    const token = jwt.sign(
      {
        usuarioID: usuario.usuarioID,
        username: usuario.username,
        rol: usuario.rol,
        permisos: userService.getPermissions(usuario.rol)
      },
      jwtSecret,
      { expiresIn }
    );

    const expiresInSeconds = expiresIn === '24h' ? 86400 : 
                            expiresIn === '7d' ? 604800 : 3600;

    res.json({
      success: true,
      token,
      expiresIn: expiresInSeconds
    });
  } catch (error) {
    console.error('❌ Error refrescando token:', error);
    res.status(500).json({
      success: false,
      error: 'Error interno del servidor'
    });
  }
});

export default router;
```

### 5. Crear Middleware de Autenticación

**`backend/src/middleware/auth-web.ts`:**

```typescript
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export interface UserPayload {
  usuarioID: number;
  username: string;
  rol: string;
  permisos: string[];
  iat?: number;
  exp?: number;
}

/**
 * Middleware de autenticación para usuarios web
 * Verifica que el request tenga un token JWT válido
 */
export function authenticateWebUser(
  req: Request,
  res: Response,
  next: NextFunction
) {
  try {
    // Obtener token del header Authorization
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'No se proporcionó token de autenticación'
      });
    }

    // Verificar token
    const jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const decoded = jwt.verify(token, jwtSecret) as UserPayload;

    // Agregar información del usuario al request
    (req as any).user = decoded;

    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(403).json({
        success: false,
        error: 'Token inválido'
      });
    }
    
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(403).json({
        success: false,
        error: 'Token expirado. Por favor, inicia sesión nuevamente.'
      });
    }

    return res.status(500).json({
      success: false,
      error: 'Error de autenticación'
    });
  }
}

/**
 * Middleware de autorización
 * Verifica que el usuario tenga el permiso necesario
 */
export function requirePermission(permission: string) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user as UserPayload;

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no autenticado'
      });
    }

    // Admin tiene todos los permisos
    if (user.permisos.includes('*')) {
      return next();
    }

    // Verificar permiso específico
    if (!user.permisos.includes(permission)) {
      return res.status(403).json({
        success: false,
        error: 'No tienes permisos para realizar esta acción'
      });
    }

    next();
  };
}

/**
 * Middleware para verificar rol específico
 */
export function requireRole(...roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = (req as any).user as UserPayload;

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Usuario no autenticado'
      });
    }

    if (!roles.includes(user.rol)) {
      return res.status(403).json({
        success: false,
        error: 'No tienes el rol necesario para esta acción'
      });
    }

    next();
  };
}
```

### 6. Proteger Rutas Existentes

**Ejemplo: Actualizar `backend/src/routes/umbrales.ts`:**

```typescript
import { authenticateWebUser, requirePermission } from '../middleware/auth-web';

// Proteger todas las rutas de umbrales
router.use(authenticateWebUser);

// Solo lectura para todos los autenticados
router.get('/', requirePermission('umbrales:read'), async (req, res) => {
  // ... código existente
});

// Crear/Editar solo con permiso de escritura
router.post('/', requirePermission('umbrales:write'), async (req, res) => {
  // ... código existente
});

router.put('/:id', requirePermission('umbrales:write'), async (req, res) => {
  // ... código existente
});

// Eliminar solo Admin
router.delete('/:id', requireRole('Admin'), async (req, res) => {
  // ... código existente
});
```

### 7. Registrar Rutas en Server

**`backend/src/server.ts`:**

```typescript
import authWebRoutes from './routes/auth-web';

// ... otras importaciones

// RUTAS DE AUTENTICACIÓN WEB
app.use('/api/auth/web', authWebRoutes);

// Proteger rutas sensibles
app.use('/api/umbrales', authenticateWebUser, umbralesRoutes);
app.use('/api/contactos', authenticateWebUser, contactosRoutes);
app.use('/api/alertas', authenticateWebUser, listarAlertasRoutes);

// Rutas públicas (sin autenticación)
app.use('/api/health', healthRoutes);
app.use('/api/test-db', testDbRoutes);
app.use('/api/auth/login', authRoutes); // Login de dispositivos móviles
```

---

## 🎨 Frontend - Implementación Completa

### 1. Crear Contexto de Autenticación

**`frontend/src/contexts/AuthContext.tsx`:**

```typescript
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { apiService } from '../services/api';

interface User {
  id: number;
  username: string;
  email: string;
  nombreCompleto: string | null;
  rol: 'Admin' | 'Agronomo' | 'Supervisor' | 'Lector';
  permisos: string[];
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
  refreshToken: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Cargar usuario desde token almacenado al iniciar
  useEffect(() => {
    const initAuth = async () => {
      const token = localStorage.getItem('authToken');
      if (token) {
        try {
          const response = await apiService.getCurrentUser();
          if (response.success && response.user) {
            setUser(response.user);
          } else {
            // Token inválido, limpiar
            localStorage.removeItem('authToken');
          }
        } catch (error) {
          console.error('Error cargando usuario:', error);
          localStorage.removeItem('authToken');
        }
      }
      setIsLoading(false);
    };

    initAuth();
  }, []);

  // Login
  const login = useCallback(async (username: string, password: string) => {
    try {
      const response = await apiService.loginWeb(username, password);
      
      if (response.success && response.token && response.user) {
        // Guardar token
        localStorage.setItem('authToken', response.token);
        
        // Guardar usuario
        setUser(response.user);
        
        // Programar refresh automático
        scheduleTokenRefresh(response.expiresIn);
      } else {
        throw new Error(response.error || 'Error en login');
      }
    } catch (error) {
      console.error('Error en login:', error);
      throw error;
    }
  }, []);

  // Logout
  const logout = useCallback(() => {
    localStorage.removeItem('authToken');
    setUser(null);
    
    // Limpiar refresh programado
    if (window.tokenRefreshTimeout) {
      clearTimeout(window.tokenRefreshTimeout);
    }
  }, []);

  // Verificar permiso
  const hasPermission = useCallback((permission: string): boolean => {
    if (!user) return false;
    
    // Admin tiene todos los permisos
    if (user.permisos.includes('*')) return true;
    
    return user.permisos.includes(permission);
  }, [user]);

  // Verificar rol
  const hasRole = useCallback((role: string): boolean => {
    return user?.rol === role;
  }, [user]);

  // Refrescar token
  const refreshToken = useCallback(async () => {
    try {
      const response = await apiService.refreshToken();
      if (response.success && response.token) {
        localStorage.setItem('authToken', response.token);
        scheduleTokenRefresh(response.expiresIn);
      }
    } catch (error) {
      console.error('Error refrescando token:', error);
      logout(); // Si falla, cerrar sesión
    }
  }, [logout]);

  // Programar refresh automático del token
  const scheduleTokenRefresh = (expiresIn: number) => {
    // Refrescar 5 minutos antes de que expire
    const refreshTime = (expiresIn - 300) * 1000;
    
    if (window.tokenRefreshTimeout) {
      clearTimeout(window.tokenRefreshTimeout);
    }
    
    window.tokenRefreshTimeout = setTimeout(() => {
      refreshToken();
    }, refreshTime);
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    hasPermission,
    hasRole,
    refreshToken
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth debe usarse dentro de AuthProvider');
  }
  return context;
};

// Extender Window para TypeScript
declare global {
  interface Window {
    tokenRefreshTimeout?: NodeJS.Timeout;
  }
}
```

### 2. Crear Página de Login

**`frontend/src/pages/Login.tsx`:**

```typescript
import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';
import { LogIn, Lock, User, AlertCircle } from 'lucide-react';

const Login: React.FC = () => {
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // Si ya está autenticado, redirigir
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      await login(formData.username, formData.password);
      navigate('/');
    } catch (err: any) {
      const errorMessage = err.response?.data?.error || 
                          err.message || 
                          'Error al iniciar sesión';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100 dark:from-dark-950 dark:to-dark-900 flex items-center justify-center p-4">
      <div className="bg-white dark:bg-dark-900 rounded-2xl shadow-2xl w-full max-w-md p-8">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-600 rounded-full mb-4">
            <LogIn className="h-8 w-8 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Iniciar Sesión
          </h1>
          <p className="text-gray-600 dark:text-dark-400">
            Ingresa tus credenciales para acceder
          </p>
        </div>

        {/* Error Message */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 rounded-lg flex items-start gap-3">
            <AlertCircle className="h-5 w-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <p className="text-sm font-medium text-red-800 dark:text-red-300">
                {error}
              </p>
            </div>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Username */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Usuario
            </label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                className="w-full pl-10 pr-4 py-3 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ingresa tu usuario"
                required
                autoComplete="username"
                disabled={loading}
              />
            </div>
          </div>

          {/* Password */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-dark-300 mb-2">
              Contraseña
            </label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type={showPassword ? 'text' : 'password'}
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="w-full pl-10 pr-12 py-3 border border-gray-300 dark:border-dark-700 rounded-lg bg-white dark:bg-dark-800 text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="Ingresa tu contraseña"
                required
                autoComplete="current-password"
                disabled={loading}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              >
                {showPassword ? '👁️' : '👁️‍🗨️'}
              </button>
            </div>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading || !formData.username || !formData.password}
            className="w-full bg-primary-600 text-white py-3 rounded-lg font-medium hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2"
          >
            {loading ? (
              <>
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                Iniciando sesión...
              </>
            ) : (
              <>
                <LogIn className="h-5 w-5" />
                Iniciar Sesión
              </>
            )}
          </button>
        </form>

        {/* Footer */}
        <div className="mt-6 text-center text-sm text-gray-600 dark:text-dark-400">
          <p>¿Problemas para acceder? Contacta al administrador</p>
        </div>
      </div>
    </div>
  );
};

export default Login;
```

### 3. Crear Componente de Protección de Rutas

**`frontend/src/components/ProtectedRoute.tsx`:**

```typescript
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

interface ProtectedRouteProps {
  children: React.ReactNode;
  permission?: string;
  role?: string;
  fallback?: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({
  children,
  permission,
  role,
  fallback
}) => {
  const { isAuthenticated, isLoading, hasPermission, hasRole } = useAuth();

  // Mostrar loading mientras verifica
  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="w-8 h-8 border-4 border-primary-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  // Si no está autenticado, redirigir a login
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // Verificar permiso si se especifica
  if (permission && !hasPermission(permission)) {
    return fallback || (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Acceso Denegado
          </h2>
          <p className="text-gray-600 dark:text-dark-400">
            No tienes permisos para acceder a esta sección
          </p>
        </div>
      </div>
    );
  }

  // Verificar rol si se especifica
  if (role && !hasRole(role)) {
    return fallback || (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            Acceso Denegado
          </h2>
          <p className="text-gray-600 dark:text-dark-400">
            No tienes el rol necesario para acceder a esta sección
          </p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
};

export default ProtectedRoute;
```

### 4. Actualizar API Service

**Agregar a `frontend/src/services/api.ts`:**

```typescript
// Agregar al objeto apiService

// AUTENTICACIÓN WEB
loginWeb: async (username: string, password: string): Promise<ApiResponse<{
  token: string;
  expiresIn: number;
  user: {
    id: number;
    username: string;
    email: string;
    nombreCompleto: string | null;
    rol: string;
    permisos: string[];
  };
}>> => {
  const response = await api.post('/api/auth/web/login', { username, password });
  return response.data;
},

logoutWeb: async (): Promise<ApiResponse<any>> => {
  const response = await api.post('/api/auth/web/logout');
  return response.data;
},

getCurrentUser: async (): Promise<ApiResponse<{
  user: {
    id: number;
    username: string;
    email: string;
    nombreCompleto: string | null;
    rol: string;
    permisos: string[];
  };
}>> => {
  const response = await api.get('/api/auth/web/me');
  return response.data;
},

refreshToken: async (): Promise<ApiResponse<{
  token: string;
  expiresIn: number;
}>> => {
  const response = await api.post('/api/auth/web/refresh');
  return response.data;
},
```

### 5. Actualizar Interceptor de Axios

**Actualizar `frontend/src/services/api.ts`:**

```typescript
// Request interceptor - Agregar token a todas las requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log(`🚀 API Request: ${config.method?.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('❌ API Request Error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor - Manejar errores de autenticación
api.interceptors.response.use(
  (response) => {
    console.log(`✅ API Response: ${response.status} ${response.config.url}`);
    return response;
  },
  async (error) => {
    logError(error, `API ${error.config?.method?.toUpperCase()} ${error.config?.url}`);
    
    // Si es error 401 (no autorizado), redirigir a login
    if (error.response?.status === 401) {
      // Solo si no estamos ya en la página de login
      if (window.location.pathname !== '/login') {
        localStorage.removeItem('authToken');
        window.location.href = '/login';
      }
    }
    
    // Mejorar mensaje de error si no tiene uno
    if (error.response?.data && !error.response.data.error && !error.response.data.message) {
      error.response.data.error = extractErrorMessage(error);
    }
    
    return Promise.reject(error);
  }
);
```

### 6. Actualizar App.tsx para Usar Autenticación

**`frontend/src/App.tsx`:**

```typescript
import { AuthProvider, useAuth } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

// Componente interno que usa el contexto
const AppContent = () => {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="w-8 h-8 border-4 border-primary-600 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <Routes>
      <Route path="/login" element={
        isAuthenticated ? <Navigate to="/" replace /> : <Login />
      } />
      
      <Route path="/" element={
        <ProtectedRoute>
          <Layout>
            {/* Tu contenido actual */}
          </Layout>
        </ProtectedRoute>
      } />
      
      {/* Otras rutas protegidas */}
      <Route path="/umbrales" element={
        <ProtectedRoute permission="umbrales:read">
          <Layout>
            <UmbralesManagement />
          </Layout>
        </ProtectedRoute>
      } />
      
      <Route path="/contactos" element={
        <ProtectedRoute permission="contactos:read">
          <Layout>
            <ContactosManagement />
          </Layout>
        </ProtectedRoute>
      } />
    </Routes>
  );
};

// Componente principal con provider
function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </BrowserRouter>
  );
}

export default App;
```

### 7. Agregar Botón de Logout en Layout

**Actualizar `frontend/src/components/Layout.tsx`:**

```typescript
import { useAuth } from '../contexts/AuthContext';
import { LogOut, User } from 'lucide-react';

const Layout: React.FC<LayoutProps> = ({ currentTab, onTabChange, children }) => {
  const { user, logout } = useAuth();
  // ... código existente

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-dark-950 flex flex-col lg:flex-row font-sans transition-colors duration-300">
      {/* Sidebar */}
      <div className="w-full lg:w-64 bg-white dark:bg-dark-900 shadow-2xl flex-shrink-0 border-r border-gray-200 dark:border-dark-700">
        {/* Header con usuario */}
        <div className="p-6 border-b border-gray-200 dark:border-dark-700">
          <h1 className="text-xl font-bold text-gray-900 dark:text-white font-display">
            🌱 Agricola Luz-Sombra
          </h1>
          <p className="text-sm text-gray-500 dark:text-dark-400 mt-1 font-medium">
            Análisis de imágenes agrícolas con ML
          </p>
          
          {/* Info de usuario */}
          {user && (
            <div className="mt-4 pt-4 border-t border-gray-200 dark:border-dark-700">
              <div className="flex items-center gap-2 text-sm">
                <User className="h-4 w-4 text-gray-400" />
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-gray-900 dark:text-white truncate">
                    {user.nombreCompleto || user.username}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-dark-400">
                    {user.rol}
                  </p>
                </div>
              </div>
              <button
                onClick={logout}
                className="mt-2 w-full flex items-center gap-2 px-3 py-2 text-sm text-gray-700 dark:text-dark-300 bg-gray-100 dark:bg-dark-800 rounded-lg hover:bg-gray-200 dark:hover:bg-dark-700 transition-colors"
              >
                <LogOut className="h-4 w-4" />
                Cerrar Sesión
              </button>
            </div>
          )}
        </div>
        
        {/* ... resto del código del sidebar */}
      </div>
      
      {/* ... resto del layout */}
    </div>
  );
};
```

### 8. Ocultar/Mostrar según Permisos

**Ejemplo en `UmbralesManagement.tsx`:**

```typescript
import { useAuth } from '../contexts/AuthContext';

const UmbralesManagement: React.FC<UmbralesManagementProps> = ({ onNotification }) => {
  const { hasPermission } = useAuth();
  
  return (
    <div>
      {/* Solo mostrar botón crear si tiene permiso */}
      {hasPermission('umbrales:write') && (
        <button onClick={handleCreate}>
          <Plus className="h-4 w-4" />
          Nuevo Umbral
        </button>
      )}
      
      {/* ... tabla de umbrales */}
      
      {/* Solo permitir editar/eliminar si tiene permiso */}
      {hasPermission('umbrales:write') && (
        <button onClick={() => handleEdit(umbral)}>
          <Edit className="h-4 w-4" />
        </button>
      )}
      
      {hasPermission('umbrales:delete') && (
        <button onClick={() => handleDelete(umbral.umbralID)}>
          <Trash2 className="h-4 w-4" />
        </button>
      )}
    </div>
  );
};
```

---

## 🔐 Sistema de Roles y Permisos

### Definición de Roles

```typescript
// backend/src/config/permissions.ts

export const ROLES = {
  Admin: {
    name: 'Admin',
    description: 'Acceso completo al sistema',
    permisos: ['*'] // Todos los permisos
  },
  Agronomo: {
    name: 'Agronomo',
    description: 'Puede gestionar umbrales, alertas y contactos',
    permisos: [
      'umbrales:read',
      'umbrales:write',
      'alertas:read',
      'alertas:write',
      'alertas:resolve',
      'contactos:read',
      'contactos:write',
      'dashboard:read',
      'historial:read',
      'dispositivos:read'
    ]
  },
  Supervisor: {
    name: 'Supervisor',
    description: 'Puede ver y resolver alertas',
    permisos: [
      'alertas:read',
      'alertas:resolve',
      'contactos:read',
      'dashboard:read',
      'historial:read'
    ]
  },
  Lector: {
    name: 'Lector',
    description: 'Solo lectura de datos',
    permisos: [
      'dashboard:read',
      'historial:read',
      'alertas:read'
    ]
  }
};

// Mapeo de permisos a rutas
export const PERMISSION_ROUTES: Record<string, string[]> = {
  'umbrales:read': ['/umbrales'],
  'umbrales:write': ['/umbrales'],
  'contactos:read': ['/contactos'],
  'contactos:write': ['/contactos'],
  'alertas:read': ['/alertas'],
  'alertas:write': ['/alertas'],
  'alertas:resolve': ['/alertas'],
  'dashboard:read': ['/dashboard'],
  'historial:read': ['/historial'],
  'dispositivos:read': ['/dispositivos'],
  'dispositivos:write': ['/dispositivos']
};
```

---

## 🔄 Flujo de Autenticación

### 1. Flujo de Login

```
Usuario ingresa username/password
         ↓
Frontend envía POST /api/auth/web/login
         ↓
Backend busca usuario en BD
         ↓
¿Usuario existe y está activo?
    NO → Error 401
    SÍ ↓
Verificar contraseña con bcrypt
         ↓
¿Contraseña correcta?
    NO → Incrementar intentos, Error 401
    SÍ ↓
Resetear intentos fallidos
Actualizar último acceso
         ↓
Generar JWT token con:
- usuarioID
- username
- rol
- permisos
         ↓
Frontend guarda token en localStorage
Frontend guarda usuario en contexto
         ↓
Redirigir a página principal
```

### 2. Flujo de Request Protegido

```
Usuario hace acción (ej: crear umbral)
         ↓
Frontend envía request con token en header
         ↓
Backend middleware authenticateWebUser
         ↓
¿Token válido y no expirado?
    NO → Error 401, redirigir a login
    SÍ ↓
Middleware requirePermission('umbrales:write')
         ↓
¿Usuario tiene permiso?
    NO → Error 403
    SÍ ↓
Ejecutar acción
         ↓
Retornar resultado
```

### 3. Flujo de Refresh de Token

```
Token está por expirar (5 min antes)
         ↓
Frontend llama POST /api/auth/web/refresh
         ↓
Backend verifica token actual
         ↓
¿Token válido y usuario activo?
    NO → Error 401, cerrar sesión
    SÍ ↓
Generar nuevo token
         ↓
Frontend actualiza token en localStorage
Programar próximo refresh
```

---

## 🛡️ Seguridad y Mejores Prácticas

### 1. Contraseñas

- ✅ Hash con bcrypt (10 rounds mínimo)
- ✅ Nunca almacenar contraseñas en texto plano
- ✅ Validar fortaleza de contraseña (mínimo 8 caracteres, mayúsculas, números)
- ✅ Bloquear cuenta después de 5 intentos fallidos (15 minutos)

### 2. Tokens JWT

- ✅ Usar secret fuerte y único en producción
- ✅ Expiración razonable (24 horas)
- ✅ Refresh automático antes de expirar
- ✅ Invalidar token en logout (opcional: blacklist)

### 3. HTTPS

- ✅ **OBLIGATORIO** en producción
- ✅ Nunca enviar tokens por HTTP

### 4. Validación

- ✅ Validar todos los inputs
- ✅ Sanitizar datos antes de guardar
- ✅ Rate limiting en endpoints de login

### 5. Logging y Auditoría

- ✅ Log de intentos de login fallidos
- ✅ Log de cambios importantes (quién, qué, cuándo)
- ✅ Alertas de seguridad (múltiples intentos fallidos)

---

## 📝 Plan de Implementación

### Fase 1: Backend (2-3 días)

**Día 1:**
- [ ] Instalar dependencias (bcrypt, jsonwebtoken)
- [ ] Crear servicio `userService.ts`
- [ ] Crear middleware `auth-web.ts`
- [ ] Crear rutas `auth-web.ts`
- [ ] Probar endpoints con Postman

**Día 2:**
- [ ] Integrar con tabla de usuarios (MAST.USERS o nueva)
- [ ] Implementar sistema de roles/permisos
- [ ] Proteger rutas existentes
- [ ] Agregar bloqueo por intentos fallidos
- [ ] Testing de seguridad

**Día 3:**
- [ ] Refinamiento y ajustes
- [ ] Documentación de API
- [ ] Crear script para usuarios iniciales

### Fase 2: Frontend (2-3 días)

**Día 1:**
- [ ] Instalar react-router-dom (si no está)
- [ ] Crear `AuthContext.tsx`
- [ ] Crear página `Login.tsx`
- [ ] Actualizar `api.ts` con métodos de auth
- [ ] Actualizar interceptor de axios

**Día 2:**
- [ ] Crear `ProtectedRoute.tsx`
- [ ] Actualizar `App.tsx` con routing
- [ ] Agregar botón logout en Layout
- [ ] Ocultar/mostrar según permisos

**Día 3:**
- [ ] Testing de flujos completos
- [ ] Manejo de errores mejorado
- [ ] Ajustes de UX
- [ ] Documentación

### Fase 3: Integración y Testing (1 día)

- [ ] Testing end-to-end
- [ ] Verificar todos los permisos
- [ ] Probar expiración de tokens
- [ ] Probar bloqueo por intentos
- [ ] Ajustes finales

---

## 🧪 Scripts de Prueba

### Crear Usuario de Prueba

```sql
-- Script para crear usuario de prueba
-- IMPORTANTE: Cambiar la contraseña después del primer login

-- Opción 1: Si usas MAST.USERS
-- (Ajustar según estructura real de la tabla)

-- Opción 2: Si creaste evalImagen.UsuarioWeb
INSERT INTO evalImagen.UsuarioWeb (
    username,
    passwordHash, -- Hash de "admin123" con bcrypt
    email,
    nombreCompleto,
    rol,
    activo,
    statusID
)
VALUES (
    'admin',
    '$2b$10$rQZ8X5KJ9L8M7N6O5P4Q3eR2T1U0V9W8X7Y6Z5A4B3C2D1E0F9G8H7I6J5K4L', -- Ejemplo, generar con bcrypt
    'admin@example.com',
    'Administrador',
    'Admin',
    1,
    1
);
```

### Generar Hash de Contraseña (Node.js)

```javascript
// script/generate-password-hash.js
const bcrypt = require('bcrypt');

const password = 'admin123';
const rounds = 10;

bcrypt.hash(password, rounds, (err, hash) => {
  if (err) {
    console.error('Error:', err);
    return;
  }
  console.log('Password:', password);
  console.log('Hash:', hash);
});
```

---

## 📋 Checklist de Implementación

### Backend
- [ ] Dependencias instaladas
- [ ] Servicio de usuarios creado
- [ ] Middleware de autenticación
- [ ] Middleware de autorización
- [ ] Rutas de auth (login, logout, me, refresh)
- [ ] Rutas protegidas con permisos
- [ ] Bloqueo por intentos fallidos
- [ ] Variables de entorno configuradas
- [ ] Testing de endpoints

### Frontend
- [ ] react-router-dom instalado
- [ ] AuthContext creado
- [ ] Página de Login
- [ ] ProtectedRoute creado
- [ ] App.tsx actualizado con routing
- [ ] Interceptor de axios actualizado
- [ ] Botón logout en Layout
- [ ] Ocultar/mostrar según permisos
- [ ] Manejo de errores de auth

### Base de Datos
- [ ] Tabla de usuarios verificada/creada
- [ ] Campos necesarios agregados
- [ ] Índices creados
- [ ] Usuario admin creado
- [ ] Scripts de prueba listos

### Seguridad
- [ ] Contraseñas hasheadas con bcrypt
- [ ] JWT secret fuerte configurado
- [ ] HTTPS configurado (producción)
- [ ] Rate limiting en login
- [ ] Bloqueo por intentos implementado
- [ ] Logging de seguridad

---

## 🎯 Ejemplo de Uso Completo

### Backend - Proteger Ruta

```typescript
// routes/umbrales.ts
import { authenticateWebUser, requirePermission } from '../middleware/auth-web';

// Todas las rutas requieren autenticación
router.use(authenticateWebUser);

// Solo lectura
router.get('/', requirePermission('umbrales:read'), async (req, res) => {
  // ... código
});

// Escritura
router.post('/', requirePermission('umbrales:write'), async (req, res) => {
  const usuarioID = (req as any).user.usuarioID; // Obtener ID del usuario actual
  // ... código usando usuarioID
});
```

### Frontend - Usar en Componente

```typescript
import { useAuth } from '../contexts/AuthContext';

const MyComponent = () => {
  const { user, hasPermission, logout } = useAuth();
  
  return (
    <div>
      <p>Bienvenido, {user?.nombreCompleto}</p>
      <p>Rol: {user?.rol}</p>
      
      {hasPermission('umbrales:write') && (
        <button>Crear Umbral</button>
      )}
      
      <button onClick={logout}>Cerrar Sesión</button>
    </div>
  );
};
```

---

## 🔍 Consideraciones Adicionales

### 1. Integración con MAST.USERS

Si `MAST.USERS` ya existe pero tiene estructura diferente:
- Verificar campos disponibles
- Mapear campos al formato necesario
- Agregar campos faltantes si es posible
- O crear tabla específica `evalImagen.UsuarioWeb`

### 2. Migración de Usuarios Existentes

Si ya hay usuarios en `MAST.USERS`:
- Generar hash de contraseñas existentes
- Asignar roles por defecto
- Activar usuarios existentes

### 3. Recuperación de Contraseña

Funcionalidad futura:
- Endpoint para solicitar reset
- Email con token de reset
- Página para cambiar contraseña

### 4. Sesiones Múltiples

Opcional:
- Permitir múltiples dispositivos
- Invalidar todas las sesiones al cambiar contraseña
- Ver sesiones activas

---

**¿Tienes alguna pregunta específica sobre la implementación?** Puedo ayudarte con cualquier parte del proceso.

