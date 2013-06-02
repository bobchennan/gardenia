int main()
{
	int a[100][200],b[200][300],c[100][300];
	int i,j,k;
	
	for(i=0;i<100;i++)
	{
		for(j=0;j<200;j++)
		{
			for(k=0;k<300;k++)
			{
				c[i][k] += a[i][j]*b[j][k];
			}
		}
	}
	return 0;
}