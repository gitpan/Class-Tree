// family.h.

class grandDad
{
	grandDad();
	~grandDad();
};

class dad: public grandDad
{
	dad();
	~dad();
};

class myself: dad
{
	myself();
	~myself();
};
