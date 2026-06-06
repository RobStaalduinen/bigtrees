# wkhtmltopdf lives at different paths per environment: a system install on the
# production Ubuntu server (/usr/local/bin) vs. the bundled wkhtmltopdf-binary
# gem used locally. Resolve in priority order so each environment finds a working
# binary: explicit override -> system install -> gem-provided binary.
wkhtmltopdf_path =
  ENV['WKHTMLTOPDF_PATH'].presence ||
  ['/usr/local/bin/wkhtmltopdf', '/usr/bin/wkhtmltopdf'].find { |path| File.executable?(path) } ||
  (Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf') rescue nil)

WickedPdf.config = {
  exe_path: wkhtmltopdf_path
}
