self: super:
{
	git = super.git.override {
		meta.priority = 4;
	};
}
