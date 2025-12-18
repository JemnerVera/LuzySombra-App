import React, { useState, useEffect, useMemo, useRef } from 'react';
import { TabType } from '../types';
import { UI_CONFIG } from '../utils/constants';
import { useAuth } from '../contexts/AuthContext';
import { Upload, Eye, BarChart3, Table, Sun, Moon, Calendar, ChevronDown, ChevronRight, Image, Gauge, Bell, Users, History, LogOut, User, Smartphone, Package, Mail, Settings, SunMoon, List, Layers, ShieldAlert, LayoutDashboard } from 'lucide-react';
import NotificationCenter from './NotificationCenter';

interface LayoutProps {
  currentTab: TabType;
  onTabChange: (tab: TabType) => void;
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ currentTab, onTabChange, children }) => {
  const { user, logout } = useAuth();
  const [isDark, setIsDark] = useState(true);
  const [expandedMenus, setExpandedMenus] = useState<Set<string>>(new Set(['consolidada', 'sistema-alertas']));
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);
  const userDropdownRef = useRef<HTMLDivElement>(null);
  const [isMainSidebarCollapsed, setIsMainSidebarCollapsed] = useState(true);
  const [isAuxSidebarCollapsed, setIsAuxSidebarCollapsed] = useState(true);

  useEffect(() => {
    // Aplicar tema al HTML
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDark]);

  // Determinar categoría actual basada en el tab activo
  const currentCategory = useMemo(() => {
    const currentTabConfig = UI_CONFIG.tabs.find(tab => tab.id === currentTab);
    return currentTabConfig?.category || null;
  }, [currentTab]);

  // Inicializar categoría seleccionada
  useEffect(() => {
    if (currentCategory && !selectedCategory) {
      setSelectedCategory(currentCategory);
    } else if (currentCategory && selectedCategory !== currentCategory) {
      setSelectedCategory(currentCategory);
    }
  }, [currentCategory, selectedCategory]);

  // Cerrar dropdown de usuario al hacer click fuera
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (userDropdownRef.current && !userDropdownRef.current.contains(event.target as Node)) {
        setUserDropdownOpen(false);
      }
    };

    if (userDropdownOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [userDropdownOpen]);

  const toggleTheme = () => {
    setIsDark(!isDark);
  };

  const getIcon = (iconName: string) => {
    if (!iconName) return null;
    switch (iconName) {
      case 'upload':
        return <Upload className="h-5 w-5" />;
      case 'eye':
        return <Eye className="h-5 w-5" />;
      case 'bar-chart-3':
        return <BarChart3 className="h-5 w-5" />;
      case 'table':
        return <Table className="h-5 w-5" />;
      case 'list':
        return <List className="h-5 w-5" />;
      case 'calendar':
        return <Calendar className="h-5 w-5" />;
      case 'image':
        return <Image className="h-5 w-5" />;
      case 'gauge':
        return <Gauge className="h-5 w-5" />;
      case 'bell':
        return <Bell className="h-5 w-5" />;
      case 'shield-alert':
        return <ShieldAlert className="h-5 w-5" />;
      case 'users':
        return <Users className="h-5 w-5" />;
      case 'user':
        return <User className="h-5 w-5" />;
      case 'history':
        return <History className="h-5 w-5" />;
      case 'smartphone':
        return <Smartphone className="h-5 w-5" />;
      case 'package':
        return <Package className="h-5 w-5" />;
      case 'mail':
        return <Mail className="h-5 w-5" />;
      case 'settings':
        return <Settings className="h-5 w-5" />;
      case 'layout-dashboard':
        return <LayoutDashboard className="h-5 w-5" />;
      default:
        return null;
    }
  };

  const toggleMenu = (menuId: string) => {
    setExpandedMenus(prev => {
      const newSet = new Set(prev);
      if (newSet.has(menuId)) {
        newSet.delete(menuId);
      } else {
        newSet.add(menuId);
      }
      return newSet;
    });
  };

  const getSubTabs = (parentId: string) => {
    return UI_CONFIG.tabs.filter(tab => (tab as any).parent === parentId);
  };

  // Obtener tabs de la categoría seleccionada
  const selectedCategoryTabs = useMemo(() => {
    if (!selectedCategory) return [];
    const category = UI_CONFIG.categories.find(cat => cat.id === selectedCategory);
    return category?.tabs || [];
  }, [selectedCategory]);

  // Obtener breadcrumbs
  const breadcrumbs = useMemo(() => {
    const category = UI_CONFIG.categories.find(cat => cat.id === selectedCategory);
    const currentTabConfig = UI_CONFIG.tabs.find(tab => tab.id === currentTab);
    
    const parts: string[] = [];
    
    if (category) {
      parts.push(category.label);
    }
    
    if (currentTabConfig) {
      // Si el tab tiene un parent, incluir el parent solo si NO es un tab de jerarquía (hasSubMenu)
      if (currentTabConfig.parent) {
        const parentTab = UI_CONFIG.tabs.find(tab => tab.id === currentTabConfig.parent);
        if (parentTab && !parentTab.hasSubMenu) {
          // Solo incluir el parent si no es un tab de jerarquía
          parts.push(parentTab.label);
        }
      }
      // Solo incluir el tab actual si NO es un tab de jerarquía
      if (!currentTabConfig.hasSubMenu) {
        parts.push(currentTabConfig.label);
      }
    }
    
    return parts;
  }, [selectedCategory, currentTab]);

  // Manejar selección de categoría
  const handleCategorySelect = (categoryId: string) => {
    setSelectedCategory(categoryId);
    const category = UI_CONFIG.categories.find(cat => cat.id === categoryId);
    if (category && category.tabs.length > 0) {
      // Navegar al primer tab de la categoría
      const firstTab = category.tabs[0];
      if (firstTab.hasSubMenu) {
        // Si tiene submenu, expandir y navegar al primer hijo
        setExpandedMenus(prev => new Set(prev).add(firstTab.id));
        const subTabs = getSubTabs(firstTab.id);
        if (subTabs.length > 0) {
          onTabChange(subTabs[0].id as TabType);
        } else {
          onTabChange(firstTab.id as TabType);
        }
      } else {
        onTabChange(firstTab.id as TabType);
      }
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-dark-950 flex flex-col lg:flex-row font-sans transition-colors duration-300">
      {/* Sidebar Principal - Categorías */}
      <div 
        className={`transition-all duration-300 bg-white dark:bg-dark-900 shadow-2xl flex-shrink-0 border-r border-gray-200 dark:border-dark-700 ${
          isMainSidebarCollapsed ? 'w-16' : 'w-64'
        }`}
        onMouseEnter={() => {
          setIsMainSidebarCollapsed(false);
          setIsAuxSidebarCollapsed(false);
        }}
        onMouseLeave={() => {
          setIsMainSidebarCollapsed(true);
          setIsAuxSidebarCollapsed(true);
        }}
      >
        {/* Header */}
        <div className="h-16 flex items-center px-6 border-b border-gray-200 dark:border-dark-700">
          <div className="flex items-center gap-2">
            <SunMoon className="h-6 w-6 text-primary-600 dark:text-primary-400 flex-shrink-0" />
            <h1 className={`text-xl font-bold text-gray-900 dark:text-white font-display transition-opacity duration-300 ${
              isMainSidebarCollapsed ? 'opacity-0 w-0 overflow-hidden' : 'opacity-100'
            }`}>
              LuzSombra
            </h1>
          </div>
        </div>

        {/* Navigation - Categorías Principales */}
        <nav className="p-4">
          <div className="space-y-1">
            {UI_CONFIG.categories.map((category) => {
              const isActive = selectedCategory === category.id;
              
              return (
                <button
                  key={category.id}
                  onClick={() => handleCategorySelect(category.id)}
                  className={`w-full flex items-center ${isMainSidebarCollapsed ? 'justify-center px-2' : 'space-x-3 px-4'} py-3 text-left rounded-lg font-medium text-sm transition-all duration-200 ${
                    isActive
                      ? 'bg-primary-600 text-white border-r-2 border-primary-400 shadow-lg'
                      : 'text-gray-600 dark:text-dark-300 hover:bg-gray-100 dark:hover:bg-dark-800 hover:text-gray-900 dark:hover:text-white hover:shadow-md'
                  }`}
                  title={isMainSidebarCollapsed ? category.label : undefined}
                >
                  {category.icon && <span className="flex-shrink-0">{getIcon(category.icon)}</span>}
                  {!isMainSidebarCollapsed && (
                    <span className="flex-1 whitespace-nowrap">
                      {category.label}
                    </span>
                  )}
                </button>
              );
            })}
          </div>
        </nav>

        {/* Footer */}
        <div className={`p-4 ${isMainSidebarCollapsed ? '' : 'border-t border-gray-200 dark:border-dark-700'}`}>
          <div className={`text-xs text-gray-500 dark:text-dark-400 text-center font-medium transition-opacity duration-300 ${
            isMainSidebarCollapsed ? 'opacity-0 h-0 overflow-hidden' : 'opacity-100'
          }`}>
            © 2024 Agricola Luz-Sombra v2.0.0
            <br />
            Powered by React + Vite
          </div>
        </div>
      </div>

      {/* Sidebar Auxiliar - Opciones de la Categoría */}
      {selectedCategory && (
        <div 
          className={`transition-all duration-300 bg-white dark:bg-dark-900 shadow-xl flex-shrink-0 border-r border-gray-200 dark:border-dark-700 ${
            isAuxSidebarCollapsed ? 'w-16' : 'w-64'
          }`}
          onMouseEnter={() => setIsAuxSidebarCollapsed(false)}
          onMouseLeave={() => setIsAuxSidebarCollapsed(true)}
        >
          <div className="h-16 flex items-center justify-center px-4 border-b border-gray-200 dark:border-dark-700">
            {isAuxSidebarCollapsed ? (
              <div className="text-xs font-semibold text-gray-700 dark:text-dark-300 text-center leading-tight">
                <div>Luz</div>
                <div>Sombra</div>
              </div>
            ) : (
              <h2 className="text-sm font-semibold text-gray-700 dark:text-dark-300 uppercase tracking-wide">
                {UI_CONFIG.categories.find(cat => cat.id === selectedCategory)?.label}
              </h2>
            )}
          </div>
          
          <nav className="p-4">
            <div className="space-y-1">
              {selectedCategoryTabs
                .filter(tab => !(tab as any).parent)
                .map((tab) => {
                  const hasSubMenu = tab.hasSubMenu;
                  const subTabs = hasSubMenu ? getSubTabs(tab.id) : [];
                  const isExpanded = expandedMenus.has(tab.id);
                  const isActive = currentTab === tab.id || subTabs.some(st => currentTab === st.id);

                  return (
                    <div key={tab.id}>
                      <button
                        onClick={() => {
                          if (hasSubMenu && subTabs.length > 0) {
                            toggleMenu(tab.id);
                            // Si tiene submenú y no hay ninguna subpestaña activa, navegar a la primera
                            const activeSubTab = subTabs.find(st => currentTab === st.id);
                            if (!activeSubTab && subTabs.length > 0) {
                              onTabChange(subTabs[0].id as TabType);
                            }
                          } else {
                            onTabChange(tab.id as TabType);
                          }
                        }}
                        className={`w-full flex items-center ${isAuxSidebarCollapsed ? 'justify-center px-2' : 'space-x-3 px-4'} py-2.5 text-left rounded-lg font-medium text-sm transition-all duration-200 ${
                          isActive
                            ? 'bg-primary-600 text-white border-r-2 border-primary-400 shadow-lg'
                            : 'text-gray-600 dark:text-dark-300 hover:bg-gray-100 dark:hover:bg-dark-800 hover:text-gray-900 dark:hover:text-white hover:shadow-md'
                        }`}
                        title={isAuxSidebarCollapsed ? tab.label : undefined}
                      >
                        {tab.icon && <span className="flex-shrink-0">{getIcon(tab.icon)}</span>}
                        {!isAuxSidebarCollapsed && (
                          <>
                            <span className="flex-1 whitespace-nowrap">
                              {tab.label}
                            </span>
                            {hasSubMenu && subTabs.length > 0 && (
                              <span className="flex-shrink-0">
                                {isExpanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                              </span>
                            )}
                          </>
                        )}
                      </button>
                      {hasSubMenu && subTabs.length > 0 && isExpanded && (
                        <div className={`mt-1 space-y-1 transition-all duration-300 ${
                          isAuxSidebarCollapsed ? 'ml-0' : 'ml-4'
                        }`}>
                          {subTabs.map((subTab) => (
                            <button
                              key={subTab.id}
                              onClick={() => onTabChange(subTab.id as TabType)}
                              className={`w-full flex items-center ${isAuxSidebarCollapsed ? 'justify-center px-2' : 'space-x-3 px-4'} py-2 text-left rounded-lg font-medium text-xs transition-all duration-200 ${
                                currentTab === subTab.id
                                  ? 'bg-primary-500 text-white border-r-2 border-primary-300 shadow-md'
                                  : 'text-gray-500 dark:text-dark-400 hover:bg-gray-100 dark:hover:bg-dark-800 hover:text-gray-700 dark:hover:text-dark-200'
                              }`}
                              title={isAuxSidebarCollapsed ? subTab.label : undefined}
                            >
                              {subTab.icon && <span className="flex-shrink-0">{getIcon(subTab.icon)}</span>}
                              {!isAuxSidebarCollapsed && (
                                <span className="whitespace-nowrap">
                                  {subTab.label}
                                </span>
                              )}
                            </button>
                          ))}
                        </div>
                      )}
                    </div>
                  );
                })}
            </div>
          </nav>
        </div>
      )}

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0 bg-gray-50 dark:bg-dark-950">
        {/* Top Bar con Breadcrumbs, Notificaciones, Tema y Usuario */}
        <div className="h-16 bg-white dark:bg-dark-900 border-b border-gray-200 dark:border-dark-700 px-4 lg:px-6 flex items-center justify-between gap-3">
          {/* Breadcrumbs */}
          <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-dark-400">
            {breadcrumbs.length > 0 && (
              <>
                {breadcrumbs.map((part, index) => (
                  <React.Fragment key={index}>
                    <span className="font-medium">{part}</span>
                    {index < breadcrumbs.length - 1 && (
                      <span className="text-gray-400 dark:text-dark-500">-</span>
                    )}
                  </React.Fragment>
                ))}
              </>
            )}
          </div>
          
          {/* Right side: Theme, Notifications, User */}
          <div className="flex items-center gap-3">
          {/* Theme Toggle */}
          <button
            onClick={toggleTheme}
            className="flex items-center justify-center p-2 rounded-lg bg-gray-100 dark:bg-dark-800 hover:bg-gray-200 dark:hover:bg-dark-700 text-gray-700 dark:text-dark-300 hover:text-gray-900 dark:hover:text-white transition-all duration-200"
            title={isDark ? 'Modo Claro' : 'Modo Oscuro'}
          >
            {isDark ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
          </button>

          {/* Notification Center */}
          <NotificationCenter />

          {/* User Dropdown */}
          {user && (
            <div className="relative" ref={userDropdownRef}>
              <button
                onClick={() => setUserDropdownOpen(!userDropdownOpen)}
                className="flex items-center justify-center w-10 h-10 rounded-full bg-primary-600 text-white hover:bg-primary-700 transition-colors focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2"
                title={user.nombreCompleto || user.username}
              >
                <span className="text-sm font-semibold">
                  {(user.nombreCompleto || user.username).charAt(0).toUpperCase()}
                </span>
              </button>

              {/* Dropdown Menu */}
              {userDropdownOpen && (
                <div className="absolute right-0 mt-2 w-56 bg-white dark:bg-dark-800 rounded-lg shadow-lg border border-gray-200 dark:border-dark-700 z-50">
                  <div className="p-4 border-b border-gray-200 dark:border-dark-700">
                    <p className="text-sm font-semibold text-gray-900 dark:text-white truncate">
                      {user.nombreCompleto || user.username}
                    </p>
                    <p className="text-xs text-gray-500 dark:text-dark-400 mt-1">
                      {user.rol}
                    </p>
                  </div>
                  <div className="p-2">
                    <button
                      onClick={() => {
                        setUserDropdownOpen(false);
                        logout();
                      }}
                      className="w-full flex items-center gap-2 px-3 py-2 text-sm text-gray-700 dark:text-dark-300 hover:bg-gray-100 dark:hover:bg-dark-700 rounded-lg transition-colors"
                    >
                      <LogOut className="h-4 w-4" />
                      Cerrar Sesión
                    </button>
                  </div>
                </div>
              )}
            </div>
          )}
          </div>
        </div>
        
        <main className="flex-1 p-4 lg:p-6 overflow-auto">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;
