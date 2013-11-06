module MyEnumerable
  SENTINAL = Object.new.freeze

  def map(&blk)
    return to_enum(:map)  if blk.nil?

    results = []
    each do |*item|
      results << yield(*item)
    end
    results
  end
  alias collect map

  def reduce(initial=SENTINAL, sym=nil, &blk)
    value = proc = list = nil
    skip = false
    if sym
      proc = sym.to_proc
      value = initial
    elsif blk
      proc = blk
      if initial == SENTINAL
        skip = true
      else
        value = initial
      end
    else
      proc = initial.to_proc
      skip = true
    end

    each do |*item|
      if item.size == 1
        item = item.first
      end
      if skip
        value = item
        skip = false
      else
        value = proc.call(value, item)
      end
    end
    value
  end
  alias inject reduce

  def to_a(*args)
    result = []
    each(*args) do |*item|
      item = item.first  if item.size == 1
      result << item
    end
    result.taint  if tainted?
    result.untrust  if untrusted?
    result
  end
  alias entries to_a

  def take(n)
    raise TypeError  unless n.respond_to?(:to_int)
    nint = n.to_int
    raise ArgumentError  if nint < 0

    result = []
    return result  if nint == 0
    each do |*item|
      item = item.first  if item.size == 1
      result << item
      break  if result.size == nint
    end
    result
  end

  def all?(&blk)
    each do |*item|
      if item.size == 1
        item = item.first
      end
      if block_given?
        return false  unless yield(*item)
      else
        return false unless item
      end
    end
    true
  end

  def any?(&blk)
    each do |*item|
      if item.size == 1
        item = item.first
      end
      if blk
        return true if yield(*item)
      else
        return true if item
      end
    end
    false
  end

  CHUNK_ALONE = :_alone
  CHUNK_SEPARATOR = :_separator
  CHUNK_SPECIALS = [CHUNK_ALONE, CHUNK_SEPARATOR]
  def chunk(&blk)
    raise ArgumentError unless blk
    thing = self
    Enumerator.new do |y|
      current_chunk = []
      current_result = nil

      thing.each do |item|
        result = yield item
        if result.is_a?(Symbol) && result.to_s.start_with?("_") && !CHUNK_SPECIALS.include?(result)
          raise
        elsif result.nil? || result == CHUNK_SEPARATOR
          if current_chunk == []
          else
            y << [current_result, current_chunk]
            current_chunk = []
          end
        elsif current_chunk == []
          current_chunk << item
          current_result = result
        elsif result == current_result && result != CHUNK_ALONE
          current_chunk << item
        else
          y << [current_result, current_chunk]
          current_chunk = [item]
          current_result = result
        end
      end
      y << [current_result, current_chunk]
    end
  end

  def flat_map(&blk)
    return to_enum(:flat_map)  if blk.nil?

    result = []
    each do |item|
      mapped = yield(item)
      if mapped.respond_to?(:to_ary)
        result.concat mapped
      else
        result << mapped
      end
    end
    result
  end
  alias collect_concat flat_map

  def count(target=SENTINAL, &blk)
    proc = if target != SENTINAL
             ->(item) { item == target }
           elsif !blk.nil?
             ->(item) { blk.call(item) }
           else
             ->(_) { true }
           end

    total = 0
    each do |item|
      total += 1  if proc.call(item)
    end
    total
  end

  def cycle(n=nil, &blk)
    if n
      raise TypeError  unless n.respond_to?(:to_int)
      nint = n.to_int
      return if  nint <= 0
    end

    inner_enumerator = nint ? (nint - 1).times : loop

    enumerator = Enumerator.new do |y|
      items = []
      each do |*item|
        y.<<(*item)
        items.<<(item)
      end
      return  if items.empty?

      inner_enumerator.each do
        x = items.each do |item|
          y.yield(*item)
        end
      end
    end

    if blk.nil?
      enumerator
    else
      enumerator.each(&blk)
    end
  end

  def find(ifnone=nil, &blk)
    return to_enum(:detect, ifnone)  if blk.nil?

    each do |*item|
      item = item.first  if item.size == 1
      return item  if yield(item)
    end

    if ifnone
      ifnone.call
    else
      nil
    end
  end
  alias detect find

  def drop(n)
    raise TypeError  unless n.respond_to?(:to_int)
    nint = n.to_int
    raise ArgumentError  unless nint >= 0

    result = []
    dropped = 0
    each do |item|
      if dropped < nint
        dropped += 1
      else
        result << item
      end
    end
    result
  end

  def drop_while(&blk)
    return to_enum(:drop_while)  if blk.nil?

    result = []
    dropping = true
    each do |*item|
      item = item.first  if item.size == 1
      if dropping && yield(item)
      else
        dropping = false
        result << item
      end
    end
    result
  end

  def each_cons(n, &blk)
    return to_enum(:each_cons, n)  if blk.nil?

    nint = n.to_int
    raise ArgumentError unless nint > 0

    current = []
    each do |*item|
      item = item.first  if item.size == 1
      if current.size < nint
        current << item
      else
        current = current.dup
        current.shift
        current << item
      end

      if current.size == nint
        yield current
      end
    end
    nil
  end

  def each_entry(*args, &blk)
    return to_enum(:each_entry, *args)  if blk.nil?

    each(*args) do |*item|
      item = item.first  if item.size == 1
      yield item
    end
    self
  end

  def each_slice(n, &blk)
    return to_enum(:each_slice, n)  if blk.nil?

    nint = n.to_int
    raise ArgumentError  unless nint > 0

    current = []
    each do |*item|
      item = item.first  if item.size == 1
      current << item
      if current.size == nint
        yield current
        current = []
      end
    end
    unless current.empty?
      yield current
    end
    nil
  end

  def each_with_index(*args, &blk)
    return to_enum(:each_with_index, *args)  if blk.nil?

    i = 0
    each(*args) do |item|
      yield item, i
      i += 1
    end
    self
  end

  def each_with_object(object, &blk)
    return to_enum(:each_with_object, object)  if blk.nil?

    each do |*item|
      item = item.first  if item.size == 1
      yield item, object
    end
    object
  end

  def find_all(&blk)
    return to_enum(:find_all)  if blk.nil?

    result = []
    each do |*item|
      item = item.first  if item.size == 1
      result << item  if yield(item)
    end
    result
  end
  alias select find_all

  def find_index(element=nil, &blk)
    return to_enum(:find_index)  if blk.nil? && element.nil?

    proc = if element
             ->(item) { item == element }
           elsif blk
             ->(item) { blk.call(item) }
           end


    each_with_index do |item, index|
      return index  if proc.call(item)
    end
    nil
  end

  SENTINAL = Object.new.freeze
  def first(n=SENTINAL)
    if n != SENTINAL
      take(n)
    else
      each do |item|
        return item
      end
    end
  end

  def take(n)
    raise TypeError  unless n.respond_to?(:to_int)
    nint = n.to_int
    raise ArgumentError  if nint < 0

    result = []
    return result  if nint == 0
    each do |*item|
      item = item.first  if item.size == 1
      result << item
      break  if result.size == nint
    end
    result
  end

  def grep(pattern, &blk)
    result = select do |item|
      pattern === item
    end

    if blk
      result = result.map(&blk)
    end

    result
  end

  def group_by(&blk)
    return to_enum(:group_by)  if blk.nil?

    hash = {}
    each do |*item|
      item = item.first  if item.size == 1
      mapped = yield(item)

      hash[mapped] ||= []
      hash[mapped] << item
    end

    hash.taint  if tainted?
    hash.untrust  if untrusted?
    hash
  end

  def include?(obj)
    each do |*item|
      item = item.first  if item.size == 1
      return true  if item == obj
    end
    false
  end
  alias member? include?

  def max_by(&blk)
    return to_enum(:max_by)  if blk.nil?

    max = nil
    max_val = SENTINAL
    each do |*item|
      item = item.first  if item.size == 1
      item_val = yield(item)

      if max_val == SENTINAL || item_val > max_val
        max = item
        max_val = item_val
      end
    end
    max
  end

  def max(&blk)
    max = SENTINAL

    proc = blk || ->(a, b) { a <=> b }

    each do |*item|
      item = item.first  if item.size == 1
      if max == SENTINAL
        max = item
      else
        diff = proc.call(item, max)
        raise ArgumentError  if diff.nil?
        if diff > 0
          max = item
        end
      end
    end

    max == SENTINAL ? nil : max
  end

  def min_by(&blk)
    return to_enum(:min_by)  if blk.nil?

    min = nil
    min_val = SENTINAL
    each do |*item|
      item = item.first  if item.size == 1
      item_val = yield(item)

      if min_val == SENTINAL || item_val < min_val
        min = item
        min_val = item_val
      end
    end
    min
  end

  def min(&blk)
    min = SENTINAL

    proc = blk || ->(a, b) { a <=> b }

    each do |*item|
      item = item.first  if item.size == 1
      if min == SENTINAL
        min = item
      else
        diff = proc.call(item, min)
        raise ArgumentError  if diff.nil?
        if diff < 0
          min = item
        end
      end
    end

    min == SENTINAL ? nil : min
  end

  def minmax_by(&blk)
    return to_enum(:minmax_by)  if blk.nil?

    min = nil
    min_val = SENTINAL
    max = nil
    max_val = SENTINAL
    each do |*item|
      item = item.first  if item.size == 1
      item_val = yield(item)

      if min_val == SENTINAL || item_val < min_val
        min = item
        min_val = item_val
      end
      if max_val == SENTINAL || item_val > max_val
        max = item
        max_val = item_val
      end
    end
    [min, max]
  end

  def minmax(&blk)
    min = SENTINAL
    max = SENTINAL

    proc = blk || ->(a, b) { a <=> b }

    each do |*item|
      item = item.first  if item.size == 1
      if min == SENTINAL
        min = item
        max = item
      else
        min_diff = proc.call(item, min)
        raise ArgumentError  if min_diff.nil?
        if min_diff < 0
          min = item
        end

        max_diff = proc.call(item, max)
        raise ArgumentError  if max_diff.nil?
        if max_diff > 0
          max = item
        end
      end
    end

    [min == SENTINAL ? nil : min, max == SENTINAL ? nil : max]
  end

  def none?(&blk)
    proc = if blk
             ->(item) { blk.call(*item) }
           else
             ->(item) { item }
           end

    each do |*item|
      item = item.first if item.size == 1
      return false if proc.call(item)
    end
    true
  end

  def one?(&blk)
    proc = if blk
             ->(item) { blk.call(*item) }
           else
             ->(item) { item }
           end

    seen = false
    each do |*item|
      item = item.first  if item.size == 1
      if proc.call(item)
        return false  if seen
        seen = true
      end
    end
    seen
  end

  def partition(&blk)
    return to_enum(:partition)  if blk.nil?

    true_array = []
    false_array = []

    each do |*item|
      item = item.first  if item.size == 1
      if yield(item)
        true_array << item
      else
        false_array << item
      end
    end

    [true_array, false_array]
  end

  def reject(&blk)
    return to_enum(:reject)  if blk.nil?

    result = []
    each do |*item|
      item = item.first  if item.size == 1
      result << item  unless yield(item)
    end
    result
  end

  def reverse_each(&blk)
    return to_enum(:reverse_each)  if blk.nil?

    items = []
    each do |*item|
      item = item.first  if item.size == 1
      items.unshift item
    end

    items.each do |item|
      yield(item)
    end
  end

  def slice_before(pattern=nil, &blk)
    raise ArgumentError  if blk.nil? && pattern.nil?

    proc = if blk
             if pattern
               ->(item) { blk.call(item, pattern.dup) }
             else
               blk
             end
           else
             ->(item) { pattern === item }
           end

    Enumerator.new do |y|
      current = []
      each do |item|
        matches = proc.call(item)
        if current == []
          current << item
        elsif matches
          y << current
          current = [item]
        else
          current << item
        end
      end
      y << current
    end
  end

  def sort_by(&blk)
    return to_enum(:sort_by)  if blk.nil?

    map do |*item|
      [yield(item), *item]
    end.sort.map do |_, *item|
      item = item.first  if item.size == 1
      item
    end
  end

  def sort(&blk)
    proc = blk || :<=>.to_proc

    data = to_a
    result = []

    until data.empty?
      min, min_index = data.each_with_index.min do |(a,_),(b,_)|
        proc.call(a, b)
      end
      result << data.delete_at(min_index)
    end

    result
  end

  def take_while(&blk)
    return to_enum(:take_while)  if blk.nil?

    result = []
    each do |item|
      break  unless yield(item)
      result << item
    end
    result
  end

  def zip(*others, &blk)
    others_ary = others.map do |other|
      if other.respond_to?(:to_ary)
        other.to_ary
      elsif other.respond_to?(:to_enum)
        other.to_enum(:each)
      end
    end

    result = []

    each do |*item|
      item = item.first  if item.size == 1
      other_vals = others_ary.map(&:first)
      others_ary = others_ary.map{ |o| o.drop(1) }
      current = [item]
      current.concat(other_vals)
      result << current
    end

    if blk
      result.each(&blk)
      nil
    else
      result
    end
  end
end
