require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require 'pry'

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, "<strong>#{term}</strong>")
  end
end

  def each_chapter(&block)
    @contents.each_with_index do | name, index |
      number = index + 1
      contents = File.read("data/chp#{number}.txt")
      yield name, number, contents
    end
  end

  def matching_chapters(query)
    results = []
    return results unless query

    each_chapter do |name, number, contents|
      matches = {}
      contents.split("\n\n").each_with_index do | paragraph, index|
        matches[index] = paragraph if paragraph.include?(query)
      end
      results << {name: name, number: number, paragraphs: matches} if matches.any?
    end
    results
  end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  @results = matching_chapters(params[:query])

  erb :search
end
