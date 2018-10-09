module ShareHelper
  def user_share_link(user, hash)
    # UHash is user.id + sha1("YA" + user.email + "YA")
    uhash = user.id.to_s + Digest::SHA1.hexdigest("YA" + user.email + "YA")
    return 'http://www.ziggi.co.il/share/' + uhash + '/' + hash
  end

  #get 'share/:uhash/:hash' => 'share#share'
  def share_link(hash)
    return user_share_link(@user, hash)
  end
end
