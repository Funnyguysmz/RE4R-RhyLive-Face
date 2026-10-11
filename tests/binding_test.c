#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#include "API.h"
void reframework_plugin_required_version(REFrameworkPluginVersion*);
bool reframework_plugin_initialize(const REFrameworkPluginInitializeParam*);
static REFLuaStateCreatedCb created;
static bool register_lua(REFLuaStateCreatedCb cb) {created=cb;return cb!=NULL;}
int main(int argc,char **argv) {
 void (*required)(REFrameworkPluginVersion*)=reframework_plugin_required_version;
 bool (*initialize)(const REFrameworkPluginInitializeParam*)=reframework_plugin_initialize;
 if(argc>1) {
  HMODULE module=LoadLibraryA(argv[1]);if(!module)return 4;
  required=(void (*)(REFrameworkPluginVersion*))GetProcAddress(module,"reframework_plugin_required_version");
  initialize=(bool (*)(const REFrameworkPluginInitializeParam*))GetProcAddress(module,"reframework_plugin_initialize");
  if(!required || !initialize)return 5;
 }
 REFrameworkPluginVersion version={0};required(&version);
 if(version.major!=1 || version.minor!=15 || strcmp(version.game_name,"RE4"))return 2;
 REFrameworkPluginFunctions functions={0};functions.on_lua_state_created=register_lua;
 REFrameworkPluginInitializeParam param={0};param.functions=&functions;
 if(!initialize(&param) || !created)return 3;
 lua_State *L=luaL_newstate();if(!L)return 1;
 luaL_openlibs(L);created(L);
 const char *test="assert(rhylive_native.version=='0.2.0'); "
 "assert(rhylive_native.receiver_version=='0.2.0' and rhylive_native.product_version=='0.2.0'); "
 "local s=rhylive_native.poll(); assert(not s.running and s.sequence==0); "
 "assert(s.values.eyeBlinkLeft==0 and s.values.jawOpen==0); "
 "local n=0;for k,v in pairs(s.values) do n=n+1 end; assert(n==52); "
 "local ok,e=rhylive_native.start(0); assert(not ok and e~=0); "
 "assert(rhylive_native.start(19237,'127.0.0.1')); "
 "assert(rhylive_native.poll().running);rhylive_native.stop(); "
 "assert(not rhylive_native.poll().running); print('LUA_5_4_3_BINDING_PASS')";
 int err=luaL_dostring(L,test);
 if(err)fprintf(stderr,"%s\n",lua_tostring(L,-1));lua_close(L);return err?1:0;
}
