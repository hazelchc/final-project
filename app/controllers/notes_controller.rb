class NotesController < ApplicationController
  def index
    matching_notes = Note.all

    @list_of_notes = matching_notes.order({ :created_at => :desc })

    render({ :template => "notes/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_notes = Note.where({ :id => the_id })

    @the_note = matching_notes.at(0)

    render({ :template => "notes/show.html.erb" })
  end

  def create
    the_note = Note.new
    the_note.body = params.fetch("query_body")
    the_note.user_id = session.fetch(:user_id)
    the_note.bookmark_id = params.fetch("input_bookmark_id")

    if the_note.valid?
      the_note.save
      redirect_to("/bookmarks/#{the_note.bookmark_id}", { :notice => "Note created successfully." })
    else
      redirect_to("/notes", { :alert => the_note.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_note = Note.where({ :id => the_id }).at(0)

    the_note.body = params.fetch("query_body")
    the_note.user_id = params.fetch("query_user_id")
    the_note.bookmark_id = params.fetch("query_bookmark_id")

    if the_note.valid?
      the_note.save
      redirect_to("/notes/#{the_note.id}", { :notice => "Note updated successfully."} )
    else
      redirect_to("/notes/#{the_note.id}", { :alert => the_note.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_note = Note.where({ :id => the_id }).at(0)

    the_note.destroy

    redirect_to("/notes", { :notice => "Note deleted successfully."} )
  end
end
