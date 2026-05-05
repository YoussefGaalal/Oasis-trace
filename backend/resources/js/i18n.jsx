import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import { useTranslation, I18nextProvider } from 'react-i18next';
import { useEffect } from 'react';
import enFull from './i18n/en.js';
import arFull from './i18n/ar.js';

const resources = {
  en: {
    translation: {
      ...enFull,
      // Login page overrides
      auth: {
        ...(enFull.auth || {}),
        login: 'Sign in to your account',
        register: 'Create your account',
        email: 'Email address',
        password: 'Password',
        confirmPassword: 'Confirm password',
        forgotPassword: 'Forgot password?',
        rememberMe: 'Remember me',
        noAccount: "Don't have an account?",
        haveAccount: 'Already have an account?',
      },
      errors: {
        unauthorized: 'Invalid credentials',
        serverError: 'Server error',
        networkError: 'Network error',
      },
    },
  },
  ar: {
    translation: {
      ...arFull,
      auth: {
        ...(arFull.auth || {}),
        login: 'تسجيل الدخول إلى حسابك',
        register: 'إنشاء حساب جديد',
        email: 'البريد الإلكتروني',
        password: 'كلمة المرور',
        confirmPassword: 'تأكيد كلمة المرور',
        forgotPassword: 'نسيت كلمة المرور؟',
        rememberMe: 'تذكرني',
        noAccount: 'ليس لديك حساب؟',
        haveAccount: 'لديك حساب بالفعل؟',
      },
      errors: {
        unauthorized: 'بيانات الدخول غير صحيحة',
        serverError: 'خطأ في الخادم',
        networkError: 'خطأ في الاتصال',
      },
    },
  },
};

i18n.use(initReactI18next).init({
  resources,
  lng: localStorage.getItem('i18nextLng') || 'en',
  fallbackLng: 'en',
  interpolation: { escapeValue: false },
});

export function useI18n() {
  const { t, i18n: i18nInstance } = useTranslation();
  return {
    t,
    dir: i18nInstance.dir(),
    language: i18nInstance.language || 'en',
    changeLanguage: (lng) => {
      i18nInstance.changeLanguage(lng);
      localStorage.setItem('i18nextLng', lng);
      document.documentElement.dir = lng === 'ar' ? 'rtl' : 'ltr';
      document.documentElement.lang = lng;
    },
  };
}

export function I18nProvider({ children }) {
  useEffect(() => {
    const lng = i18n.language;
    document.documentElement.dir = lng === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = lng;
  }, []);
  return <I18nextProvider i18n={i18n}>{children}</I18nextProvider>;
}

export default i18n;
