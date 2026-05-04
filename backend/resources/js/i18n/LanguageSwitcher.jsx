import { MaterialSymbol } from 'react-material-symbols';
import { useI18n } from '../i18n.jsx';

export default function LanguageSwitcher() {
  const { language, changeLanguage } = useI18n();

  const toggle = () => {
    changeLanguage(language === 'en' ? 'ar' : 'en');
  };

  return (
    <button
      onClick={toggle}
      className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-[#F4F4EF] hover:bg-[#E3E3DE] transition-all text-[#002819] font-semibold text-sm"
      title={language === 'en' ? 'Switch to Arabic' : 'التبديل إلى الإنجليزية'}
    >
      <MaterialSymbol icon="translate" size={18} />
      <span className="font-bold">
        {language === 'en' ? 'عربي' : 'EN'}
      </span>
    </button>
  );
}
