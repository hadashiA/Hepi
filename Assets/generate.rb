# coding: utf-8

dir './hd'

font 'misaki_gothic.ttf', :size => 60.pt do 
  '広奈さんお誕生日おめでとう'.each_char do |char|
    "#{char}.png" << char
  end
end
