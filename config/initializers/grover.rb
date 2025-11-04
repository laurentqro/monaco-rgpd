Grover.configure do |config|
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
    # Use system Chromium in production
    executable_path: ENV.fetch("GROVER_CHROMIUM_PATH", "/usr/bin/chromium"),
    # Chrome flags for Docker environment
    launch_args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-gpu"
    ]
  }
end
