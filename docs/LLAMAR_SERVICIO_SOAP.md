# Llamar al Servicio SOAP - Guía Simple

## 🎯 Situación

**El servicio SOAP ya está funcionando.** Solo necesitas llamarlo desde tu código.

---

## 📋 Qué Necesitas de IT/DBA

### **Preguntas Simples:**

1. **URL del servicio SOAP:**
   - ¿Cuál es la URL completa?
   - Ejemplo: `https://ws-agromigiva.agricolaandrea.com/AuthService.asmx`

2. **Método a llamar:**
   - ¿Cómo se llama el método? (ej: `Login`, `Authenticate`, `GetToken`)

3. **Credenciales:**
   - ¿Qué credenciales necesito enviar?
   - ¿Usuario/contraseña? ¿API Key?

4. **Ejemplo de llamada:**
   - ¿Pueden darme un ejemplo de cómo llamarlo?
   - ¿Con curl? ¿Con Postman? ¿Con código?

5. **Token/Respuesta:**
   - ¿Qué retorna el servicio?
   - ¿Cómo uso lo que retorna en el Web Service?

---

## 💻 Implementación Simple

### **Opción 1: Usar Librería SOAP (Recomendado)**

**Instalar:**
```bash
npm install soap
```

**Código:**
```typescript
import soap from 'soap';

class SoapAuthService {
  private soapClient: any;
  private token: string | null = null;

  async getToken(): Promise<string> {
    // Si ya tenemos token, retornarlo
    if (this.token) {
      return this.token;
    }

    // URL del servicio SOAP (obtener de IT)
    const wsdlUrl = process.env.SOAP_WSDL_URL || 'https://ws-agromigiva.agricolaandrea.com/AuthService.asmx?WSDL';
    
    // Crear cliente SOAP
    const client = await soap.createClientAsync(wsdlUrl);
    
    // Llamar método (ajustar según lo que IT indique)
    const [result] = await client.LoginAsync({
      username: process.env.SOAP_USERNAME || '',
      password: process.env.SOAP_PASSWORD || ''
    });

    // Extraer token (ajustar según estructura de respuesta)
    this.token = result.LoginResult.Token;
    
    return this.token;
  }
}

export const soapAuthService = new SoapAuthService();
```

---

### **Opción 2: Request HTTP Directo (Si no quieres usar librería)**

**Código:**
```typescript
import axios from 'axios';

class SoapAuthService {
  private token: string | null = null;

  async getToken(): Promise<string> {
    if (this.token) {
      return this.token;
    }

    // URL del servicio SOAP
    const soapUrl = process.env.SOAP_ENDPOINT || 'https://ws-agromigiva.agricolaandrea.com/AuthService.asmx';
    
    // XML request (ajustar según lo que IT indique)
    const soapRequest = `<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <Login xmlns="http://tempuri.org/">
      <username>${process.env.SOAP_USERNAME}</username>
      <password>${process.env.SOAP_PASSWORD}</password>
    </Login>
  </soap:Body>
</soap:Envelope>`;

    // Llamar servicio SOAP
    const response = await axios.post(soapUrl, soapRequest, {
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/Login' // Ajustar según IT
      }
    });

    // Parsear respuesta XML (usar xml2js)
    const parser = require('xml2js').parseString;
    const result = await new Promise((resolve, reject) => {
      parser(response.data, (err: any, result: any) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    // Extraer token (ajustar según estructura)
    this.token = result['soap:Envelope']['soap:Body'][0].LoginResponse[0].LoginResult[0].Token[0];
    
    return this.token;
  }
}
```

---

## 🔗 Usar Token en Web Service

**Una vez que obtienes el token del SOAP, lo usas en el Web Service:**

```typescript
import { soapAuthService } from './services/soapAuthService';

class WebServiceClient {
  async callEndpoint(endpoint: string, data: any) {
    // Obtener token del SOAP
    const token = await soapAuthService.getToken();

    // Llamar Web Service con token
    const response = await axios.post(
      `${this.baseURL}${endpoint}`,
      data,
      {
        headers: {
          'X-SOAP-Token': token, // O el header que IT especifique
          'Content-Type': 'application/json'
        }
      }
    );

    return response.data;
  }
}
```

---

## 📝 Variables de Entorno

```env
# SOAP Service
SOAP_WSDL_URL=https://ws-agromigiva.agricolaandrea.com/AuthService.asmx?WSDL
SOAP_ENDPOINT=https://ws-agromigiva.agricolaandrea.com/AuthService.asmx
SOAP_USERNAME=tu-usuario
SOAP_PASSWORD=tu-password

# Web Service
WEBSERVICE_URL=https://ws-agromigiva.agricolaandrea.com
```

---

## 🧪 Testing

### **Probar con Postman:**

1. **Crear nueva request**
2. **Método:** POST
3. **URL:** `https://ws-agromigiva.agricolaandrea.com/AuthService.asmx`
4. **Headers:**
   - `Content-Type: text/xml; charset=utf-8`
   - `SOAPAction: http://tempuri.org/Login` (ajustar según IT)
5. **Body (raw XML):**
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
     <soap:Body>
       <Login xmlns="http://tempuri.org/">
         <username>tu-usuario</username>
         <password>tu-password</password>
       </Login>
     </soap:Body>
   </soap:Envelope>
   ```
6. **Enviar y ver respuesta**

---

## ✅ Checklist

- [ ] Obtener URL del servicio SOAP de IT/DBA
- [ ] Obtener método a llamar
- [ ] Obtener credenciales
- [ ] Obtener ejemplo de request/response
- [ ] Probar llamada con Postman
- [ ] Implementar en código
- [ ] Integrar con Web Service Client
- [ ] Probar flujo completo

---

## 📞 Preguntas para IT/DBA

**Solo necesitas estas 5 cosas:**

1. **URL del servicio SOAP:** `_________________`
2. **Método a llamar:** `_________________`
3. **Credenciales:** Usuario: `_____` / Password: `_____`
4. **Ejemplo de request:** (pueden darte un XML de ejemplo)
5. **Cómo usar el token:** ¿En qué header lo envío al Web Service?

---

**Fecha de creación**: 2024-11-17


