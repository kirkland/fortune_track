module ApplicationHelper
  def display_date(date_object)
    return '(no date)' if date_object.nil?

    date_object.strftime('%Y-%m-%d')
  end
end
