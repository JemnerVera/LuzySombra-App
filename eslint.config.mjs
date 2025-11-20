// ESLint configuration for monorepo
// Individual projects have their own ESLint configs

export default [
  {
    ignores: [
      'node_modules/**',
      'backend/node_modules/**',
      'frontend/node_modules/**',
      'backend/dist/**',
      'frontend/dist/**',
      '.next/**',
      'out/**',
      'build/**'
    ]
  }
];
