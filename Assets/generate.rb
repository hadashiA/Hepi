# coding: utf-8

dir './x1'

font 'misaki_gothic.ttf', :size => 20.pt do 
  '広奈さんお誕生日おめでとう'.each_char do |char|
    "#{char}.png" << char
  end
end
