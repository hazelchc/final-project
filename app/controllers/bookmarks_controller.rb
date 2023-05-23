class BookmarksController < ApplicationController

  before_action(:load_current_user)

  def load_current_user
    @current_user = User.where({ :id => session[:user_id] }).at(0)
  end 

  def index
    # matching_bookmarks = Bookmark.all
    matching_bookmarks = @current_user.bookmarks
    
    @list_of_bookmarks = matching_bookmarks.order({ :created_at => :desc })

    render({ :template => "bookmarks/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_bookmarks = Bookmark.where({ :id => the_id })

    @the_bookmark = matching_bookmarks.at(0)

    @raw_recipe = @the_bookmark.recipe_to_bookmark.content[/#{"#"}(.*?)#{"Bon"}/m, 1]

    # @ingredient = @raw_recipe[/#{"Ingredients:"}(.*?)#{"Instructions:"}/m, 1]
    # @instruction = @raw_recipe[/#{"Instructions:"}(.*?)#{"***:"}/m, 1]

    render({ :template => "bookmarks/show.html.erb" })
  end

  def create
    the_bookmark = Bookmark.new
    the_bookmark.user_id = params.fetch("query_user_id")
    the_bookmark.message_id = params.fetch("query_message_id")

    if the_bookmark.valid?
      the_bookmark.save
      redirect_to("/bookmarks", { :notice => "Bookmark created successfully." })
    else
      redirect_to("/bookmarks", { :alert => the_bookmark.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_bookmark = Bookmark.where({ :id => the_id }).at(0)

    the_bookmark.user_id = params.fetch("query_user_id")
    the_bookmark.message_id = params.fetch("query_message_id")

    if the_bookmark.valid?
      the_bookmark.save
      redirect_to("/bookmarks/#{the_bookmark.id}", { :notice => "Bookmark updated successfully."} )
    else
      redirect_to("/bookmarks/#{the_bookmark.id}", { :alert => the_bookmark.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_bookmark = Bookmark.where({ :id => the_id }).at(0)

    the_bookmark.destroy

    redirect_to("/bookmarks", { :notice => "Bookmark deleted successfully."} )
  end
end
