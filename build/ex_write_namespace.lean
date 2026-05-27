-- Write: the namespace should match the module name 'StringUtils'
-- Currently it's 'StrUtil' — fix it
namespace StrUtil

def shout (s : String) : String := s.toUpper ++ "!!!"

end StrUtil

#eval StrUtil.shout "hello"
