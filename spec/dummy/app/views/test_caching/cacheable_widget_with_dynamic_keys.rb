class Views::TestCaching::CacheableWidgetWithDynamicKeys < Erector::Widget

  cacheable :current_user

  def content
    text DateTime.current
  end

  def current_user
    'the current user'
  end

end
