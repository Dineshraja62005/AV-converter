const eslint = require('eslint');
const tseslint = require('@typescript-eslint/eslint-plugin');
const reactPlugin = require('eslint-plugin-react');
const reactHooksPlugin = require('eslint-plugin-react-hooks');

module.exports = [
  {
    files: ['src/**/*.{js,jsx,ts,tsx}'],
    plugins: {
      '@typescript-eslint': tseslint,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin
    },
    languageOptions: {
      parser: require('@typescript-eslint/parser'),
      parserOptions: {
        ecmaFeatures: {
          jsx: true
        }
      }
    },
    rules: {
      // TypeScript-specific rules
      '@typescript-eslint/no-explicit-any': 'warn',
      
      // React-specific rules
      'react/prop-types': 'off',
      'react/react-in-jsx-scope': 'off',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn'
    }
  },
  {
    ignores: ['dist/', 'build/', 'node_modules/']
  }
];