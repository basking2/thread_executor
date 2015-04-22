require 'thread_executor'
require 'test-unit'

class ThreadExecutorTest < Test::Unit::TestCase

  # Test that this works.
  def test_workers
    e = ThreadExecutor::Executor.new 10
    r = 0
    begin
      f = 100.times.map { |i| e.call { i + 1 } }
      r = f.reduce(0) { |v, f| v + f.value }

    ensure
      e.finish
    end

    assert_equal 5050, r
  end

  # Check that exceptions raised in jobs propogate out.
  def test_raising
    e = ThreadExecutor::Executor.new 10
    f1 = e.call { Object.new.this_does_not_exit }
    f2 = e.call { raise Exception.new("test exception") }
    begin
      assert_raise NoMethodError do
        f1.value 
      end
      assert_raise Exception do
        f2.value
      end
    ensure
      e.finish
    end
  end
end
