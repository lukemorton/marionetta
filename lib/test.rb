def a(*args)
  yield args if block_given?
end

def b(*args, &block)
  a(*args, &block)
end

b do |str|
  puts str, 'cool'
end