module ApplicationHelper
  #<%= google_analytics 'UA-XXXXXX-XX' %>
  def google_analytics(id)
    content_tag :script, :type => 'text/javascript' do
      "var _gaq = _gaq || [];
	    _gaq.push(['_setAccount', '#{id}']);
	    _gaq.push(['_trackPageview']);
	    (function() {
	    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	    })();".html_safe
    end if false && id && Rails.env == 'production'
  end

  def google_analytics_header
    content_tag :script, :type => 'text/javascript' do
      "function trackOutboundLink(link, category, action) {
	    try {
		    _gaq.push(['_trackEvent', category , action]);
		    } catch(err){}

		    setTimeout(function() {
		    document.location.href = link.href;
		    }, 100);
		}".html_safe
    end if false && Rails.env == 'production'
  end
end
