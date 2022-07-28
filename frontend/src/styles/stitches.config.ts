import { createStitches } from '@stitches/react';

export const {
  styled,
  css,
  globalCss,
  keyframes,
  getCssText,
  theme,
  createTheme,
  config,
} = createStitches({
  theme: {
    colors: {
      gray100: '#FAFAFA',
      gray200: '#F5F6FA',
      gray300: '#EEEEEE',
      gray400: '#A4B4C4',
      gray500: '#717E95',
      gray600: '#44485D',

      violet500: '#766BE7',

      green100: '#C8F9CD',
      green500: '#2BB739',

      red100: '#FFD2D2',
      red500: '#DE6262',

      blue100: "#DDEBFF",
      blue500: "#4B88E4",
    },
  },
  media: {
    bp1: '(min-width: 480px)',
  },
});