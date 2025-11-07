/**
 * Type declarations for piexifjs
 * This module doesn't have TypeScript definitions, so we create them here
 */

declare module 'piexifjs' {
  export const ImageIFD: any;
  export const ExifIFD: any;
  
  export function load(binary: string): any;
  export function dump(exifObject: any): string;
  export function insert(exifString: string, jpeg: string): string;
  export function remove(jpeg: string): string;
}

