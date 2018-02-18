class StaffRankController < ApplicationController
  before_filter :login_check

  #get 'rank/:id' => 'staff_rank#info'
  def info
    json = {}
    json['id'] = params[:id]
    rank = {'1' => 0, '2' => 0, '3' => 0, '4' => 0, '5' => 0}
    comments = []
    StaffRank.find_all_by_staff_id(params[:id], :order => 'updated_at DESC').each do |r|
      if r[:rank] and r[:rank] > 0
        rank[r[:rank].to_s] = rank[r[:rank].to_s] + 1;
      end

      # Skip comment of this user
      next if r.user_id == @user.id

      # Skip empty comments
      next if not r.comment or r.comment.length < 1
      comment = {:rank => r.rank, :comment => r.comment,
                 :user => r.user.name.split(' ')[0],
                 :date => r.updated_at}
      comments.push comment
    end
    json['rank'] = rank
    json['comments'] = comments
    user_rank = {'rank' => 0, 'comment' => ''}
    s = StaffRank.find_by_user_id_and_staff_id(@user[:id], params[:id])
    user_rank['rank'] = s[:rank] if s
    user_rank['comment'] = s[:comment] if s

    json['user_rank'] = user_rank

    render :text => JSON.dump(json)
  end

  #match 'rank' => 'staff_rank#rank', :via => [:post]
  def rank
    rank = params[:rank].to_i if params[:rank]
    return render :status => 500 if rank and (rank < 0 or rank > 5)
    s = StaffRank.find_or_create_by_user_id_and_staff_id(@user[:id], params[:id])

    s.update_attributes :rank => rank if rank
    s.update_attributes :comment => params[:comment] if params[:comment]

    redirect_to "/rank/" + params[:id]
  end
end
