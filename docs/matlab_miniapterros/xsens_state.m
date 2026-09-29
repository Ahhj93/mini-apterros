function st = xsens_state()
st.buf  = uint8([]);
st.last = struct('angles_rad',[0 0 0],'gyro_rad_s',[0 0 0],'freeacc',[0 0 0]);
end
