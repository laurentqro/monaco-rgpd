require "prawn"
require "prawn/table"

class PdfRenderer
  def render(html_content, document_type)
    Prawn::Document.new do |pdf|
      # Use DejaVu Sans font for full UTF-8 support (French characters)
      font_path = Rails.root.join("app", "assets", "fonts", "DejaVuSans.ttf")
      pdf.font_families.update("DejaVu" => {
        normal: font_path.to_s
      })
      pdf.font "DejaVu"

      # Add header
      pdf.text "Monaco RGPD", size: 24
      pdf.move_down 10
      pdf.text document_type.to_s.titleize, size: 18
      pdf.move_down 20

      # For MVP, we'll render simplified content
      # Strip HTML tags for basic rendering
      clean_content = strip_html_tags(html_content)

      # Render content with basic formatting
      render_content(pdf, clean_content)

      # Add footer with page numbers
      pdf.number_pages "<page> / <total>",
        at: [ pdf.bounds.right - 50, 0 ],
        align: :right,
        size: 10
    end.render
  end

  private

  def strip_html_tags(html)
    # Remove HTML tags and decode entities
    html.gsub(/<[^>]*>/, "")
        .gsub(/&nbsp;/, " ")
        .gsub(/&amp;/, "&")
        .gsub(/&lt;/, "<")
        .gsub(/&gt;/, ">")
        .gsub(/&quot;/, '"')
        .strip
  end

  def render_content(pdf, content)
    lines = content.split("\n")

    lines.each do |line|
      next if line.strip.empty?

      # Handle headers (lines starting with #)
      if line.start_with?("# ")
        pdf.move_down 10 unless pdf.cursor == pdf.bounds.top - 70
        pdf.text line.gsub(/^#\s+/, ""), size: 16
        pdf.move_down 10
      elsif line.start_with?("## ")
        pdf.move_down 8
        pdf.text line.gsub(/^##\s+/, ""), size: 14
        pdf.move_down 6
      elsif line.start_with?("- ")
        # Handle bullet points
        pdf.text line, size: 11, indent_paragraphs: 20
        pdf.move_down 4
      else
        # Regular text
        pdf.text line, size: 11
        pdf.move_down 6
      end
    end
  end
end
