// luaproc.cpp
// Extension lib defines
#define LIB_NAME "luaproc"
#define MODULE_NAME "luaproc"

// include the Defold SDK
#include <dmsdk/sdk.h>

int luaopen_luaproc( lua_State *L, const char *name );

static void LuaInit(lua_State* L)
{
    int top = lua_gettop(L);

    // Register lua names
    luaopen_luaproc(L, MODULE_NAME);

    lua_pop(L, 1);
    assert(top == lua_gettop(L));
}

static dmExtension::Result AppInitializeluaproc(dmExtension::AppParams* params)
{
    dmLogInfo("AppInitializeluaproc");
    return dmExtension::RESULT_OK;
}

static dmExtension::Result Initializeluaproc(dmExtension::Params* params)
{
    // Init Lua
    LuaInit(params->m_L);
    dmLogInfo("Registered %s Extension", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeluaproc(dmExtension::AppParams* params)
{
    dmLogInfo("AppFinalizeluaproc");
    return dmExtension::RESULT_OK;
}

static dmExtension::Result Finalizeluaproc(dmExtension::Params* params)
{
    dmLogInfo("Finalizeluaproc");
    return dmExtension::RESULT_OK;
}

static dmExtension::Result OnUpdateluaproc(dmExtension::Params* params)
{
    //dmLogInfo("OnUpdateluaproc");
    return dmExtension::RESULT_OK;
}

static void OnEventluaproc(dmExtension::Params* params, const dmExtension::Event* event)
{
    switch(event->m_Event)
    {
        case dmExtension::EVENT_ID_ACTIVATEAPP:
            dmLogInfo("OnEventluaproc - EVENT_ID_ACTIVATEAPP");
            break;
        case dmExtension::EVENT_ID_DEACTIVATEAPP:
            dmLogInfo("OnEventluaproc - EVENT_ID_DEACTIVATEAPP");
            break;
        case dmExtension::EVENT_ID_ICONIFYAPP:
            dmLogInfo("OnEventluaproc - EVENT_ID_ICONIFYAPP");
            break;
        case dmExtension::EVENT_ID_DEICONIFYAPP:
            dmLogInfo("OnEventluaproc - EVENT_ID_DEICONIFYAPP");
            break;
        default:
            dmLogWarning("OnEventluaproc - Unknown event id");
            break;
    }
}

// Defold SDK uses a macro for setting up extension entry points:
//
// DM_DECLARE_EXTENSION(symbol, name, app_init, app_final, init, update, on_event, final)

// luaproc is the C++ symbol that holds all relevant extension data.
// It must match the name field in the `ext.manifest`
DM_DECLARE_EXTENSION(luaproc, LIB_NAME, AppInitializeluaproc, AppFinalizeluaproc, Initializeluaproc, OnUpdateluaproc, OnEventluaproc, Finalizeluaproc)
