UbuWebRSS::Application.routes.draw do
  root :to => 'index#index'
  scope :format => true, :constraints => { :format => 'rss' } do
    get 'feed/all' => 'feed#news'
  end
end
