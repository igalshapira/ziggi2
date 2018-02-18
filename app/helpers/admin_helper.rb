module AdminHelper
  def goto_users_page(title, page, total_pages)
    return "" if page < 1
    return "" if page > total_pages
    return '<a href="/admin/users/' + page.to_s + '">' + title + '</a>'
  end

  def goto_events_page(title, page, total_pages)
    return "" if page < 1
    return "" if page > total_pages
    return '<a href="/admin/events/' + page.to_s + '">' + title + '</a>'
  end
end
