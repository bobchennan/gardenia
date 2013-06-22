int main()
{
	int a[20][20],b[20][30],c[20][30];
	int i,j,k;
	
	for(i=0;i<20;i++)
	{
		for(j=0;j<20;j++)
		{
			for(k=0;k<30;k++)
			{
				c[i][k] += a[i][j]*b[j][k];
			}
		}
	}
	return 0;
}