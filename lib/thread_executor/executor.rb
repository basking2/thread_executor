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

#
module ThreadExecutor

# A threaded executor.
#
# Procs can be given to this executor and are
# executed according to the availability of threads.
#
# = Use
#
#     # Make an executor.
#     executor = ThreadExecutor::Executor.new 10
#
#     begin
#
#       # Dispatch 100 jobs across the 10 threads.
#       futures = 100.times.map { executor.call { do_long_running_work } }
#
#       # Collect the results.
#       results = futures.map { |future| future.value }
#
#     ensure
#       # Clean up the threads.
#       executor.finish
#     end
#
class Executor

  # Build a new executor with +size+ Processor objects.
  # The default size is 2.
  #
  # Each Processor contains a work queue and a running ruby Thread
  # which will process the elements in the work queue.
  #
  # This Executor will insert elements into the work queue.
  # 
  # Use of the Executor is not thread safe. If more than one thread
  # submit work to Processor objects through this Executor, the
  # Executor must be protected by a lock of some sort.
  def initialize size=2
    @processors = []

    size.times do
      @processors << Processor.new
    end
  end

  # Enqueues the block in a processor queue with the fewest tasks.
  # 
  # Returns a future for the result.
  def call(&t)
    min_processor = @processors[0]
    min_size = min_processor.size
    @processors.each do |p|
      min_size2 = p.size
      if min_size > min_size2
        min_processor = p
        min_size = min_size2
      end
    end

    # Forward the user's block to the processor.
    min_processor.call &t
  end

  # Sum of all queue depths.
  def size
    @processors.reduce(0) {|x,y| x + y.size}
  end

  # Shutdown and join all worker threads.
  def finish
    @processors.each do |p|
      p.finish
    end
  end
end

end # module Sake
