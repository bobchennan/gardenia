#include<iostream>
#include<fstream>
#include<string.h>
using namespace std;

#define TOTALNUM 50
#define RNUM 15
#define JNUM 23
#define INUM 46
#define MAXWL 6
#define CODEL 6
#define MXLBNUM 5
#define MXLBL 5

#define NOTINDX 46
#define LHIINDX 47
#define CMPINDX 48
#define SYSINDX 49

char name[TOTALNUM][MAXWL+1],code[TOTALNUM][CODEL+1],functcode[RNUM][CODEL+1];
char label[MXLBNUM][MXLBL+1];
int labelloc[MXLBNUM];
/*
int match(char *list[],char *t)
{
	for(int i=0;i<TOTALNUM;i++)
		if(strcmp(t,list[i])==0)return i;
	return -1;
}
*/
void toBin(char *bin,int len,int dec)	//decimal to signed binary of len digits
{
	int tIndex=len,tNum=dec,tDig;
	tNum=(tNum<0)?-tNum:tNum;
	for(int i=0;i<len;i++)bin[i]='0';
	while(tNum>0)
	{
		tDig=(tNum%2)+48;
		tNum/=2;
		tIndex--;
		bin[tIndex]=tDig;
	}
	bin[len]='\0';
	if(dec<0)
	{
		for(i=0;i<len;i++)
			bin[i]=(bin[i]=='0'?'1':'0');	//若是负数，逐位取反再加一
		bool c=true;
		for(i=len-1;i>=0;i--)
		{
			if(!c)break;
			if(bin[i]=='1')bin[i]='0';
			else {bin[i]='1'; c=false;}
		}
	}
}
		
void main(int argc,char **argv)
{
	fstream rulefile,infile,outfile;
	rulefile.open(argv[1],ios_base::in);
	infile.open(argv[2],ios_base::in);
	outfile.open(argv[3],ios_base::out);
	if(!rulefile){cout<<"no rule file!"<<endl;exit(1);}
	for(int i=0;i<TOTALNUM;i++)	//read rulefile
		rulefile>>name[i]>>code[i];
	for(i=0;i<RNUM;i++)
		rulefile>>name[i]>>functcode[i];

	char tname[MAXWL+1],*tInstr,*s,tRegch[6],tAddrch[27],tcode[33],tImmch[17];	//match instruction or label
	char blank5[6]="00000",blank16[17]="0000000000000000";
	tInstr=new char(30);s=tInstr;
	int index,labelindex=0,instrIndex=0;
	int tReg,tImm;
	while(!infile.eof())	//搜索行标号并存储
	{
		infile>>tname;
		index=-1;
		for(i=0;i<TOTALNUM;i++)
		{
			if(strcmp(tname,name[i])==0){index=i;break;}
		}
		if(index==-1)
		{
			tname[strlen(tname)-1]='\0';	//delete ':'
			strcpy(label[labelindex],tname);
			labelloc[labelindex++]=instrIndex;
			continue;
		}
		else
			infile>>tInstr;
		instrIndex++;
	}

	infile.close();
	infile.clear();
	infile.open(argv[2],ios_base::in);
	instrIndex=0;
	while(!infile.eof())
	{
		infile>>tname;
		index=-1;
		for(i=0;i<TOTALNUM;i++)
		{
			if(strcmp(tname,name[i])==0){index=i;break;}
		}
		if(index==-1)continue;
		else
		{
			tcode[0]='\0';
			strcat(tcode,code[index]);	//output binary code
			infile>>tInstr;
			if(index<RNUM)
			{
				tInstr++;
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				tInstr+=(tReg>9?4:3);
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				tInstr+=(tReg>9?4:3);
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				strcat(tcode,blank5);
				strcat(tcode,functcode[index]);
			}
			else if(index<JNUM)
			{
				int tindex=-1;
				for(int i=0;i<labelindex;i++)
				{
					if(strcmp(tInstr,label[i])==0){tindex=i;break;}
				}
				if(tindex==-1){cout<<"no such label!"<<endl;exit(1);}
				toBin(tAddrch,26,instrIndex-labelloc[tindex]);
				strcat(tcode,tAddrch);
			}
			else if(index<INUM)
			{
				tInstr++;
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				tInstr+=(tReg>9?3:2);
				sscanf(tInstr,"%d",&tImm);
				toBin(tImmch,16,tImm);
				tInstr=strchr(tInstr,'$');
				tInstr++;
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				strcat(tcode,tImmch);
			}
			else if(index==NOTINDX)
			{
				tInstr++;
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				strcat(tcode,blank5);
				tInstr+=(tReg>9?4:3);
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				strcat(tcode,blank5);
				strcat(tcode,functcode[index]);
			}
			else if(index==LHIINDX)
			{
				tInstr++;
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,blank5);
				strcat(tcode,tRegch);
				tInstr+=(tReg>9?3:2);
				sscanf(tInstr,"%d",&tImm);
				toBin(tImmch,16,tImm);
				strcat(tcode,tImmch);
			}
			else if(index==CMPINDX)
			{
				tInstr++;
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				tInstr+=(tReg>9?4:3);
				sscanf(tInstr,"%d",&tReg);
				toBin(tRegch,5,tReg);
				strcat(tcode,tRegch);
				strcat(tcode,blank16);
			}
			else if(index==SYSINDX)
			{
				sscanf(tInstr,"%d",&tImm);
				toBin(tAddrch,26,tImm);
				strcat(tcode,tAddrch);
			}
			instrIndex++;
		}
		outfile<<tcode<<endl;
	}
	cout<<"done!"<<endl;
	infile.close();
	rulefile.close();
	outfile.close();
//	tInstr=s;
//	free(tInstr);
	exit(0);
}
