module MyEnumerable

  def map(&blk)
  end
  alias collect map

  def reduce(initial, sym=nil, &blk)
  end
  alias inject reduce

  def to_a(*args)
  end
  alias entries to_a

  def take(n)
  end

  def all?(&blk)
  end

  def any?(&blk)
  end

  def chunk(&blk)
  end

  def flat_map(&blk)
  end
  alias collect_concat flat_map

  def count(target=SENTINAL, &blk)
  end

  def cycle(n=nil, &blk)
  end

  def find(ifnone=nil, &blk)
  end
  alias detect find

  def drop(n)
  end

  def drop_while(&blk)
  end

  def each_cons(n, &blk)
  end

  def each_entry(*args, &blk)
  end

  def each_slice(n, &blk)
  end

  def each_with_index(*args, &blk)
  end

  def each_with_object(object, &blk)
  end

  def find_all(&blk)
  end
  alias select find_all

  def find_index(element=nil, &blk)
  end

  def first(n)
  end

  def grep(pattern, &blk)
  end

  def group_by(&blk)
  end

  def include?(obj)
  end
  alias member? include?

  def max_by(&blk)
  end

  def max(&blk)
  end

  def min_by(&blk)
  end

  def min(&blk)
  end

  def minmax_by(&blk)
  end

  def minmax(&blk)
  end

  def none?(&blk)
  end

  def one?(&blk)
  end

  def partition(&blk)
  end

  def reject(&blk)
  end

  def reverse_each(&blk)
  end

  def slice_before(pattern=nil, &blk)
  end

  def sort_by(&blk)
  end

  def sort(&blk)
  end

  def take_while(&blk)
  end

  def zip(*others, &blk)
  end
end
