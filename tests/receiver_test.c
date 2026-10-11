/* Loopback tests run without REFramework or a game process. */
#include "../src/receiver.c"
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"FAIL line %d: %s\n",__LINE__,#x); return 1; } } while (0)
static void put32(unsigned char *p,uint32_t v) {
 p[0]=(unsigned char)(v>>24);p[1]=(unsigned char)(v>>16);p[2]=(unsigned char)(v>>8);p[3]=(unsigned char)v;
}
static void face(unsigned char *p,float value) {
 memset(p,0,272);memcpy(p,"/Face",5);p[8]=',';memset(p+9,'f',52);
 for(int i=0;i<52;++i){float v=value;uint32_t bits;memcpy(&bits,&v,4);put32(p+64+4*i,bits);}
}
int main(void) {
 unsigned char packet[272],bundle[568];float out[52];face(packet,0.25f);
 CHECK(rhylive_parse(packet,sizeof(packet),out)==1);
 for(int i=0;i<52;++i) CHECK(out[i]==0.25f);
 face(packet,2);CHECK(rhylive_parse(packet,272,out)==1 && out[51]==1);
 face(packet,-1);CHECK(rhylive_parse(packet,272,out)==1 && out[0]==0);
 face(packet,0.25f);put32(packet+64,0x7fc00000);out[0]=0.75f;
 CHECK(rhylive_parse(packet,272,out)==-1 && out[0]==0.75f);
 face(packet,0.25f);CHECK(rhylive_parse(packet,271,out)==-1);
 packet[9]='i';CHECK(rhylive_parse(packet,272,out)==-1);
 face(packet,0.25f);packet[6]=1;CHECK(rhylive_parse(packet,272,out)==-1);
 face(packet,0.25f);memset(bundle,0,sizeof(bundle));memcpy(bundle,"#bundle",7);
 put32(bundle+16,272);memcpy(bundle+20,packet,272);
 face(packet,0.5f);put32(bundle+292,272);memcpy(bundle+296,packet,272);
 CHECK(rhylive_parse(bundle,sizeof(bundle),out)==1 && out[0]==0.5f);
 put32(bundle+292,276);out[0]=0.75f;
 CHECK(rhylive_parse(bundle,sizeof(bundle),out)==-1 && out[0]==0.75f);
 CHECK(rhylive_start(0,"127.0.0.1")!=0);
 CHECK(rhylive_start(19238,"invalid")!=0);
 CHECK(rhylive_start(19238,"127.0.0.1")==0);
 SOCKET sender=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);CHECK(sender!=INVALID_SOCKET);
 struct sockaddr_in target={0};target.sin_family=AF_INET;target.sin_port=htons(19238);
 CHECK(InetPtonA(AF_INET,"127.0.0.1",&target.sin_addr)==1);
 face(packet,0.5f);
 CHECK(sendto(sender,(const char*)packet,272,0,(struct sockaddr*)&target,sizeof(target))==272);
 packet[9]='i';CHECK(sendto(sender,(const char*)packet,272,0,(struct sockaddr*)&target,sizeof(target))==272);
 RhySnapshot snapshot={0};
 for(int i=0;i<100;++i){rhylive_snapshot(&snapshot);if(snapshot.packets==2)break;Sleep(10);}
 CHECK(snapshot.running && snapshot.packets==2 && snapshot.sequence==1 && snapshot.rejected==1);
 for(int i=0;i<52;++i) CHECK(snapshot.values[i]==0.5f);
 /* GetTickCount64 has a coarser tick than Sleep's requested duration. */
 Sleep(100);rhylive_snapshot(&snapshot);CHECK(snapshot.age_ms>=50);
 closesocket(sender);rhylive_stop();rhylive_snapshot(&snapshot);CHECK(!snapshot.running);
 CHECK(rhylive_start(19238,"127.0.0.1")==0);rhylive_snapshot(&snapshot);
 CHECK(snapshot.running && snapshot.sequence==0 && snapshot.packets==0);rhylive_stop();
 puts("OSC_PARSE_AND_LOOPBACK_PASS");return 0;
}
