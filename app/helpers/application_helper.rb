module ApplicationHelper
  def display_date(date_object)
    date_object.strftime('%Y-%m-%d')
  end
end
