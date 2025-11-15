HUDPresenter.present_orig = HUDPresenter.present
function HUDPresenter:present(params,...)
	if HEVHUD:ShouldUseOriginalHUDPresenter() then 
		return self:present_orig(params,...)
	else
		--HEVHUD:ShowHint(params)
	end
end