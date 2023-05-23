class RecipesController < ApplicationController
  before_action(:load_current_user)

  def load_current_user
    @current_user = User.where({ :id => session[:user_id] }).at(0)
  end 

  def destroy
    the_id = params.fetch("path_id")
    the_recipe = Recipe.where({ :id => the_id }).at(0)

    the_recipe.destroy

    redirect_to("/recipes", { :notice => "Recipe deleted successfully."} )
  end

  def index
    matching_recipes = Recipe.all

    @list_of_recipes = matching_recipes.order({ :created_at => :desc })

    render({ :template => "recipes/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_recipes = Recipe.where({ :id => the_id })

    @the_recipe = matching_recipes.at(0)

    render({ :template => "recipes/show.html.erb" })
  end

  def create
    the_recipe = Recipe.new
    the_recipe.user_id = @current_user.id
    the_recipe.ingredient = params.fetch("query_ingredient")

    if the_recipe.valid?
      the_recipe.save

      system_message = Message.new
      system_message.recipe_id = the_recipe.id
      system_message.role = "system"
      message_A = "You are a chef. The user has #{the_recipe.ingredient} left in the fridge. Suggest a recipe that includes #{the_recipe.ingredient}. Modify the recipe based on the user's additional request."

      message_B = " The format of the recipe should include a section of '#Ingredients:' and a section of 'Instructions:'. At the end of the recipe, say 'Bon Appétit!' " 
      system_message.content = message_A + message_B 
      system_message.save

      user_message = Message.new
      user_message.recipe_id = the_recipe.id
      user_message.role = "user"
      user_message.content = "Can you suggest a recipe that contains #{the_recipe.ingredient}?"
      user_message.save

      client = OpenAI::Client.new(access_token: ENV.fetch("GPT4_KEY"))

      api_messages_array = Array.new

      recipe_messages = Message.where({ :recipe_id => the_recipe.id }).order(:created_at)

      recipe_messages.each do |the_message|
        message_hash = { :role => the_message.role, :content => the_message.content }

        api_messages_array.push(message_hash)
      end 

      response = client.chat(
        parameters: {
            model: "gpt-3.5-turbo",
            messages: api_messages_array,
            temperature: 1.0,
        }
      )

      assistant_message = Message.new
      assistant_message.recipe_id = the_recipe.id
      assistant_message.role = "assistant"
      assistant_message.content = response.fetch("choices").at(0).fetch("message").fetch("content")
      assistant_message.save
      
      redirect_to("/recipes/#{the_recipe.id}", { :notice => "Recipe created successfully." })

    else
      redirect_to("/recipes", { :alert => the_recipe.errors.full_messages.to_sentence })
    end
  end
end

  def update
    the_id = params.fetch("path_id")
    the_recipe = Recipe.where({ :id => the_id }).at(0)

    the_recipe.ingredient = params.fetch("query_ingredient")

    if the_recipe.valid?
      the_recipe.save
      redirect_to("/recipes/#{the_recipe.id}", { :notice => "Recipe updated successfully."} )
    else
      redirect_to("/recipes/#{the_recipe.id}", { :alert => the_recipe.errors.full_messages.to_sentence })
    end
  end
