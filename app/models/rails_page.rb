class RailsPage < Page
  display_name "Non-cached page"
  attr_accessor :breadcrumbs, :cached

  def find_by_url(url, live=true, clean=true)
    found_page = super
    if found_page.nil? || found_page.is_a?(FileNotFoundPage)
      url = clean_url(url) if clean
      self if url.starts_with?(self.url)
    else
      found_page
    end
  end
  
  def url=(path)
    @url = path
  end
  
  def url
    @url || super
  end
  
  def cache?
    true if @cached
  end
  
  def cache!
    @cached = true
  end
  
  def uncache!
    @cached = false
  end
  
  def build_parts_from_hash!(content)
    content.each do |k,v|
      (part(k) || parts.build(:name => k.to_s, :filter_id => "")).content = v
    end
  end
  
  def assign_ivars(ivars)
    @mailer_vars = ivars
  end
  
  alias_method "tag:old_breadcrumbs", "tag:breadcrumbs"
  tag 'breadcrumbs' do |tag|
    if tag.locals.page.is_a?(RailsPage) && tag.locals.page.breadcrumbs
      tag.locals.page.breadcrumbs
    else
      render_tag('old_breadcrumbs', tag)
    end
  end
end