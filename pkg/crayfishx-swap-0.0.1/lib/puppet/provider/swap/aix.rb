require 'open3'
Puppet::Type.type(:swap).provide :aix do
  desc "Manages swap sizes on AIX"

  confine :operatingsystem => :AIX
  defaultfor :operatingsystem => :AIX

  commands :chps => 'chps'

  def ppsize
    Open3.popen3("/usr/sbin/lslv #{@resource[:device]}") do |stdin, stdout, stderr|
      stdout.each do |line|
        if line.match(/.*PP SIZE:[\t ]+([\d]+) .*/)
          return Integer($1)
        end
      end
    end
  end


  def strip_unit(str)
    str.gsub(/[^0-9]/,'')
  end

  def mb_to_pp(mb)
    Float(Integer(mb)/ppsize).ceil.to_i
  end

  def size
    cursize = ""
    Open3.popen3("/usr/sbin/swap -l") do |stdin, stdout, stderr|
      stdout.each do |line|
        larr = line.split(/[\t ]+/)
        cursize=larr[3].gsub(/MB/,'M') if larr[0] = "/dev/#{@resource[:device]}"
      end
    end
    return @resource[:size] if strip_unit(cursize) == strip_unit(@resource[:size])
    size_is = mb_to_pp(strip_unit(cursize))
    size_should = mb_to_pp(strip_unit(@resource[:size]))

    if size_is == size_should
      return @resource[:size]
    else
      return cursize
    end
  end

  def size=(newval)
    cursize=mb_to_pp(strip_unit(size))
    newsize=mb_to_pp(strip_unit(newval))
    args=[]
    if newsize > cursize
      args << "-s"
      args << newsize-cursize
    else
      args << "-d"
      args << cursize-newsize
    end
    args << @resource[:device]
    chps(*args)
  end
end


