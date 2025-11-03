Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "2cm",
      bottom: "2cm",
      left: "2.5cm",
      right: "2.5cm"
    },
    print_background: true,
    prefer_css_page_size: true,
    display_header_footer: true,
    header_template: "<div></div>",
    footer_template: '<div style="font-size:9px; text-align:center; width:100%; color:#666;">
      <span class="pageNumber"></span> / <span class="totalPages"></span>
    </div>'
  }
end
