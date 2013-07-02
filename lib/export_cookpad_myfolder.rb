# -*- coding: utf-8 -*-
require "export_cookpad_myfolder/version"
require 'rubygems'
require 'mechanize'
require 'pry'

module ExportCookpadMyfolder

  agent = Mechanize.new {|agent| agent.user_agent_alias = 'Mac Safari' }

  top = agent.get('https://cookpad.com/login')

  mypage = top.form_with(:action => 'https://cookpad.com/login') do |f|
    f.login = ENV["COOKPAD_USER"]
    f.password = ENV["COOKPAD_PASS"]
  end.click_button

  myfolder = agent.get('http://cookpad.com/myfolder')

  # TODO:choice tag by command line
  filted_page = myfolder.link_with(text: "リア充ごはん").click

  recipes = []

  loop do

    recipes += filted_page.search("//div[@class='recipe-preview']").map do |recipe|

      a = recipe.search("a[@class='recipe-title font13']").first
      {
        title: a.text,
        url: a.attribute("href").value,
        ingredients: recipe.search("div[@class='material ingredients']").first.text
      }
    end

    next_link = filted_page.link_with(text: "次へ»")

    break unless next_link

    filted_page = next_link.click
  end

  recipes.each do |recipe|
    puts <<EOS
#### #{recipe[:title]}
#{recipe[:url]}
#{recipe[:ingredients]}

EOS
  end

end
