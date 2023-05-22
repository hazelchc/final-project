class MessagesController < ApplicationController
  
  def add_user_bookmark
    b = Bookmark.new
    b.user_id = params.fetch("the_user_id")
    b.message_id = params.fetch("the_message_id")
    b.save 

    redirect_to "/bookmarks", :notice => "Bookmarked recipe"
  end

  def create
    the_message = Message.new
    the_message.content = params.fetch("query_content")
    the_message.role = params.fetch("query_role")
    the_message.recipe_id = params.fetch("query_recipe_id")

    if the_message.valid?
      the_message.save
      
      the_recipe = Recipe.where({ :id => the_message.recipe_id }).at(0)

      client = OpenAI::Client.new(access_token: ENV.fetch("GPT4_KEY"))

      api_messages_array = Array.new

      recipe_messages = Message.where({ :recipe_id => the_recipe.id }).order(:created_at)

      recipe_messages.each do |the_recipe|
        message_hash = { :role => the_recipe.role, :content => the_recipe.content }

        api_messages_array.push(message_hash)
      end

      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: api_messages_array,
          temperature: 1.0,
        },
      )
      
      assistant_message = Message.new
      assistant_message.recipe_id = the_message.recipe_id
      assistant_message.role = "assistant"
      assistant_message.content = response.fetch("choices").at(0).fetch("message").fetch("content")
      assistant_message.save

      redirect_to("/recipes/#{the_message.recipe_id}", { :notice => "Message created successfully." })

    else
      redirect_to("/recipes/#{the_message.recipe_id}", { :alert => the_message.errors.full_messages.to_sentence })
    end 
  end
end



#   def update
#     the_id = params.fetch("path_id")
#     the_message = Message.where({ :id => the_id }).at(0)

#     the_message.content = params.fetch("query_content")
#     the_message.role = params.fetch("query_role")
#     the_message.recipe_id = params.fetch("query_recipe_id")

#     if the_message.valid?
#       the_message.save
#       redirect_to("/messages/#{the_message.id}", { :notice => "Message updated successfully."} )
#     else
#       redirect_to("/messages/#{the_message.id}", { :alert => the_message.errors.full_messages.to_sentence })
#     end
#   end

  def destroy
    the_id = params.fetch("path_id")
    the_message = Message.where({ :id => the_id }).at(0)

    the_message.destroy

    redirect_to("/messages", { :notice => "Message deleted successfully."} )
  end


