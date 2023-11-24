module ApplicationHelper
  # Iterate over flash messages, display different styles for alerts and notices
  def display_flash_message
    classes_notice = "mx-auto border-l-4 w-auto py-2 px-4 text-lg shadow-md shadow-black mt-4 bg-blue-100 border-blue-300"
    classes_alert = "mx-auto border-l-4 w-auto py-2 px-4 text-lg shadow-md shadow-black mt-4 bg-red-100 border-red-300"

    flash_messages = flash.map do |flash_message|
      # If the type of flash message is an alert display red background, else it is blue
      classes = flash_message[0] == "alert" ? classes_alert : classes_notice
      content_tag(:div, flash_message[1], class: classes)
    end
    flash_messages.join.html_safe
  end

  # This method enables the users to be able to sort their test runs
  def sortable(column, title=nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil

    # This will decide which arrow to show the user how their results are being sorted
    # We are using HTML entity for the arrows
    arrow = css_class.include?('desc') ? "&darr;": "&uarr;" if css_class
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"

    # Wrapping the title and arrow in #raw allows for the title and arrow to be
    # displayed together in the view
    link_to raw("#{title} #{arrow}"), {:sort => column, :direction => direction}, {:class => css_class}
  end
end
