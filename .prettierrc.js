const general = {
  singleQuote: true,
  semi: true,
  trailingComma: 'es5',
  quoteProps: 'as-needed', // prettier default
  bracketSpacing: true, // prettier default
  bracketSameLine: false, // prettier default
  arrowParens: 'always', // prettier default
  proseWrap: 'preserve', // prettier default
  singleAttributePerLine: false, // prettier default
  embeddedLanguageFormatting: 'auto', // prettier default
  // printWidth: // configured in .editorconfig->max_line_length
  // useTabs: // configured in .editorconfig->indent_size
  // tabWidth: // configured in .editorconfig->indent_style
  // endOfLine: // configured in .editorconfig->end_of_line
};

module.exports = {
  ...general,
};
