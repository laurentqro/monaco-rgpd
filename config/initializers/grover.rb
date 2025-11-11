Grover.configure do |config|
  # Determine the Chrome executable path based on environment
  chrome_path = if Rails.env.development? || Rails.env.test?
    # Use Puppeteer's Chrome in development/test
    # Try to find Puppeteer's Chrome in common locations
    puppeteer_chrome = Dir.glob(File.expand_path("~/.cache/puppeteer/chrome/*/chrome-*/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing")).max
    puppeteer_chrome || ENV.fetch("GROVER_CHROMIUM_PATH", "/usr/bin/chromium")
  else
    # Use system Chromium in production
    ENV.fetch("GROVER_CHROMIUM_PATH", "/usr/bin/chromium")
  end

  config.options = {
    format: "A4",
    margin: {
      top: "2cm",
      bottom: "2cm",
      left: "2.5cm",    # Wider left/right margins for binding
      right: "2.5cm"
    },
    print_background: true,        # Preserve CSS backgrounds
    prefer_css_page_size: true,    # Honor @page CSS rules if present
    display_header_footer: true,
    header_template: "<div></div>",  # Empty header
    footer_template: '<div style="font-size:9px; text-align:center; width:100%; color:#666;"><span class="pageNumber"></span> / <span class="totalPages"></span></div>',  # Page numbers
    executable_path: chrome_path,
    wait_until: "domcontentloaded",  # Don't wait for all network resources (faster in tests)
    # Chrome flags for Docker environment
    launch_args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-gpu"
    ]
  }
end
