#include <cstdio>
#include <cstring>
#include <ctime>
#include <cstdlib>

int a[30][30],b[30][30],c[30][30];

int main(){
	srand(unsigned(time(0)));
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			a[i][j]=rand()%20;
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			b[i][j]=rand()%20;
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			for(int k=0;k<30;++k)
				c[i][k]+=a[i][j]*b[j][k];
	FILE *read=fopen("ram_data.txt","w");
	fprintf(read,"@00\n");
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			fprintf(read,"%02x %02x %02x %02x //%d\n",a[i][j]/256/256/256%256,a[i][j]/256/256%256,a[i][j]/256%256,a[i][j]%256,a[i][j]);
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			fprintf(read,"%02x %02x %02x %02x //%d\n",b[i][j]/256/256/256%256,b[i][j]/256/256%256,b[i][j]/256%256,b[i][j]%256,b[i][j]);
	fclose(read);
	
	read=fopen("answer.txt","w");
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			fprintf(read,"%02x %02x %02x %02x //%d\n",a[i][j]/256/256/256%256,a[i][j]/256/256%256,a[i][j]/256%256,a[i][j]%256,a[i][j]);
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			fprintf(read,"%02x %02x %02x %02x //%d\n",b[i][j]/256/256/256%256,b[i][j]/256/256%256,b[i][j]/256%256,b[i][j]%256,b[i][j]);
	for(int i=0;i<30;++i)
		for(int j=0;j<30;++j)
			fprintf(read,"%02x %02x %02x %02x //%d\n",c[i][j]/256/256/256%256,c[i][j]/256/256%256,c[i][j]/256%256,c[i][j]%256,c[i][j]);
	fclose(read);
	return 0;
}