# Copyright (c) 2015, Sam Baskinger <basking2@yahoo.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of thread_executor nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'thread'

module ThreadExecutor

# A processor is a Queue feeding a Thread.
class Processor

  # Create Processor.
  #
  # This will create a new Queue and start a new ruby Thread.
  #
  # The created thread will block until work is inserted n the Queue
  # using #call.
  #
  # To avoid leaking active threads you must call #finish to stop
  # processing and join the Thread behind this object.
  # Once this object is finished it may not be used again. It
  # should be discarded.
  #
  # Typically the user should never create or use this class, but 
  # use an Executor, though there is nothing wrong in using this
  # directly..
  def initialize
    @q = Queue.new
    @t = Thread.new do
      while true do
        promise, task = @q.deq

        # This is how we shut down the thread cleanly.
        break if promise.nil? && task.nil?

        begin
          promise.value = task.call
        rescue Exception => e
          promise.exception = e
        end
      end
    end
  end

  # Signal that the worker thread should exit.
  #
  # More precisely, this enqueues a stop request
  # into the work queue, which, when encountered,
  # causes the worker thread to cleanly exit and 
  # take no more work.
  def shutdown
    @q.enq [nil, nil]
  end

  # Adds a task, creates a Promise and returns a Future.
  def call(&t)
    p = Promise.new
    @q.enq [ p, t ]
    p.future
  end

  # Return the size of the work queue.
  def size
    @q.size
  end

  # Call #shutdown and join the thread.
  # 
  # This will block until the thread is joined.
  #
  # When this returns this object is unusable and should
  # be discarded.
  def finish
    shutdown
    @t.join
  end
end

end # module ThreadExecutor
