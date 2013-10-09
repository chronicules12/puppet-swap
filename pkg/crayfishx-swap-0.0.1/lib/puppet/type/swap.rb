Puppet::Type.newtype(:swap) do

  newparam(:device) do
    desc "Device to create the swap on"
    isnamevar
  end

  newproperty(:size) do
    desc "Size in MB specified as nM"
    munge do |value|
      value.to_s
    end

  end
end


