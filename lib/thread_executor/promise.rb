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

require 'thread_executor/future'

module ThreadExecutor

# A Promise is a container for a value that a Processor will compute.
#
# It contains locking objects to ensure that the value is communicated
# safely from the Processor 's Thread to user's Thread.
#
# A user typically never touches this object directly but 
# examines the Future.
class Promise
  attr_reader :value, :exception, :future

  def initialize()
    @value     = nil
    @exception = nil
    @ready     = false
    @lock      = Mutex.new
    @cond      = ConditionVariable.new
    @no_result = true
    @future    = Future.new(self)
  end

  # Wait until this Promise is fulfilled and return the value
  # If an exception was raised, it is reraised here.
  def value
    @lock.synchronize do

      while ! @ready do
        @cond.wait @lock
      end

      raise @exception if @exception

      @value
    end
  end

  def ready?
    @ready
  end

  def value= v
    @lock.synchronize do
      @value = v
      @ready = true
      @cond.signal
    end
  end

  def exception= e
    @lock.synchronize do
      @exception = e
      @ready = true
      @cond.signal
    end
  end
end

end # module ThreadExecutor
