// Environment configuration for Next.js
export const config = {
  // Use relative URLs - works in both development and production
  // Next.js automatically handles API routes, so we don't need absolute URLs
  apiUrl: process.env.NEXT_PUBLIC_API_URL || '',
  googleSheetsConfig: process.env.GOOGLE_SHEETS_CREDENTIALS_BASE64 || '',
  googleSheetsToken: process.env.GOOGLE_SHEETS_TOKEN_BASE64 || '',
  googleSheetsSpreadsheetId: process.env.GOOGLE_SHEETS_SPREADSHEET_ID || '',
  googleSheetsSheetName: process.env.GOOGLE_SHEETS_SHEET_NAME || '',
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
};
